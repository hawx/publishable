# Publishable

Publishable provides a layer of gloss over SFTP so that a list of items can be
published on to a remote server. It contains a `Site` module and a `File`
module, along with a specification for an `ItemInterface` if not working with
the file system. These can be mixed into classes that expose the correct
interface to make them easy to `#publish`.

See [`example/publish`](example/publish) for a basic implementation.
