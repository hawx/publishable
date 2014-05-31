# -*- encoding: utf-8 -*-
require File.expand_path("../lib/publishable/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "publishable"
  s.author       = "Joshua Hawxwell"
  s.email        = "m@hawx.me"
  s.summary      = "Easier publishing of static sites"
  s.homepage     = "http://github.com/hawx/publishable"
  s.version      = Publishable::VERSION

  s.description  = <<-DESC
    Provides mixins for allowing a couple of classes representing a
    website to be published using SFTP.
  DESC

  s.files        = %w(README.md Rakefile LICENSE)
  s.files       += Dir["{lib,spec}/**/*"] & `git ls-files`.split("\n")
  s.test_files   = Dir["{spec}/**/*"] & `git ls-files`.split("\n")
end
