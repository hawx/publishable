# -*- encoding: utf-8 -*-
require File.expand_path("../lib/publishable/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "publishable"
  s.author       = "Joshua Hawxwell"
  s.email        = "m@hawx.me"
  s.summary      = "A short summary of what it does."
  s.homepage     = "http://github.com/hawx/publishable"
  s.version      = Publishable::VERSION

  s.description  = <<-DESC
    A long form description. Nicely indented and wrapped at ~70 chars.
    Here's a measuring line for you. (Don't keep this in when releasing.)
    ----------------------------------------------------------------------
  DESC

  # s.add_dependency 'some-gem', '~> X.X.X'
  # s.add_development_dependency 'some-gem', '~> X.X.X'

  s.files        = %w(README.md Rakefile LICENCE)
  s.files       += Dir["{lib,spec}/**/*"] & `git ls-files`.split("\n")
  s.test_files   = Dir["{spec}/**/*"] & `git ls-files`.split("\n")
end
