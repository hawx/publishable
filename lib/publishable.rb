require 'highline'
require 'digest/md5'
require 'pstore'
require 'net/sftp'

module Publishable
  # This is the interface items must fulfill.
  module ItemInterface
    # @return [String] Contents of the item, this is what will be written to the
    #   remote file.
    def contents; end

    # @return [String] Digest of the items's contents, to be stored and
    #   compared, so that it can be determined whether the item has been
    #   modified or not.
    def digest; end

    # @return [String] Url the item will have when written. This will be
    #   appended to +config[:base]+ as given to {Publishable#publish} to give
    #   the remote path to write to.
    def url; end
  end

  # This module may be included into any class which has the #path instance
  # method so that it can conform to the ItemInterface. It provides standard
  # (and obvious) implementations for the methods.
  module File
    def contents
      ::File.read path.to_s
    end

    def digest
      ::Digest::MD5.file(path.to_s).hexdigest
    end

    # The url is defined as the file's path with a leading slash.
    def url
      ::File.join "/", path.to_s
    end
  end

  # Include {Publishable::Site} into an object that responds to #each, which
  # returns items that conform to {ItemInterface}, to provide the #publish
  # method to the object. The #publish method takes configuration settings and
  # publishes the items given by #each to a remote server over SFTP.
  module Site

    # Publish the items, this expects the object to respond to #each. Each item
    # must also respond to methods as detailed above.
    #
    # @param store [String] Path to the file where data should be kept to
    #   determine if a file has changed.
    #
    # @param config [Hash{Symbol=>String}] Configuraton for the server.
    # @opts config [String] :host
    # @opts config [String] :base
    # @opts config [String] :user
    # @opts config [String] :pass
    #
    # @param output [Block]
    def publish(store, config, &output)
      # If an output block is not given, create a basic default. In reality this
      # should be good enough 99% of the time.
      unless block_given?
        output = lambda do |event, local, remote|
          case event
          when :no_change
            puts "No change"
          when :uploaded
            puts "Uploaded #{local} -> #{remote}"
          end
        end
      end

      # Load the digest database with PStore
      hashes = PStore.new(::File.expand_path(store))

      # Fix up config, get password if not given, then check we have keys
      unless config.key?(:pass)
        config[:pass] = Highline.new.ask("Enter password: ") {|q| q.echo = "*" }
      end

      config[:base] = Pathname.new(config[:base])

      [:host, :base, :user, :pass].each do |key|
        raise "#publish must be passed :#{key} in config" unless config.key?(key)
      end

      # Find all items that have changed before starting the SFTP session, so if
      # nothing has changed we can exit early.
      changed = []
      each do |item|
        hashes.transaction do
          changed << item unless hashes[item.url] == item.digest
        end
      end

      unless changed.size > 0
        output.call(:no_change, nil, nil)
        exit
      end

      # Now begin the SFTP session, since items have changed.
      Net::SFTP.start config[:host], config[:user], password: config[:pass] do |sftp|

        # Helper method to check whether the path given exists on the remote
        # server.
        def sftp.exist?(path)
          lstat!(path.to_s)
          true
        rescue Net::SFTP::StatusException
          false
        end

        changed.each do |item|
          # Calculate remote path
          remote = config[:base] + item.url[1..-1]

          # Update hashes
          hashes.transaction do
            hashes[item.url] = item.digest
          end

          # Make directories as required
          remote.dirname.descend do |sub_dir|
            sftp.mkdir!(sub_dir) unless sftp.exist?(sub_dir)
          end

          # Now write the file, force encoding to fix issues
          sftp.file.open(remote.to_s, 'w') do |f|
            f.puts item.contents.force_encoding('binary')
          end

          # Finally say that the item has been uploaded
          output.call(:uploaded, item.url, remote)
        end
      end
    end

  end
end
