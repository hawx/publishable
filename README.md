# Publishable

Publishable provides a thin layer over SFTP so that a list of items can be
published to a remote server.

It contains a `Site` module and a `File` module, along with a specification for
an `ItemInterface` if not working with the file system. These can be mixed into
classes that expose the correct interface to make them easy to `#publish`.

See [`example/publish`](example/publish) for a basic implementation.


## Explain...

A `Site` must implement:

- `#each(&block)`, that enumerates objects conforming to `ItemInterface`.

And `ItemInterface` says you must implement:

- `#contents`, that returns the contents to be written;
- `#digest`, a hash to determine whether the item has changed;
- `#url`, the url that the item lives at.

There is also the `File` module which has default implementations of
`ItemInterface` for a file on the file system, it requires that the method
`#path` is defined to return the path to the file.

The class that includes `Site` has a `#publish(store, config)` method defined on
it, where:

- `store` is the path to a local cache for digests;
- `config` is a hash containing:
  * `host`, the host to publish to;
  * `base`, the base path to write to;
  * `user`, the username to use;
  * `pass`, the password to use, if omitted you will be prompted.
