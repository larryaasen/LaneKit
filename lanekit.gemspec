# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanekit/version'

Gem::Specification.new do |spec|
  spec.name          = "lanekit"
  spec.version       = LaneKit::VERSION
  spec.authors       = ["Larry Aasen"]
  spec.email         = ["larryaasen@gmail.com"]
  spec.summary       = %q{an iOS Objective-C code generator for integration with RestKit.}
  spec.description   = %q{LaneKit is an iOS Objective-C code generator for integration with RestKit. It generates
models, resource providers, table views, and full iOS apps with mimimal effort. There is support for unit testing with SenTestingKit
including fixtures and tests. LaneKit is a command line app written in Ruby and packaged as a Ruby Gem.}
  spec.homepage      = "https://github.com/LarryAasen/LaneKit"
  spec.license       = "MIT"
  
  spec.files = Dir["lib/**/*.rb"] + Dir["lib/**/*.erb"] + Dir.glob("lib/{template}/**/*") + %w{ bin/lanekit README.md LICENSE }

  spec.executables   = %w{ lanekit }
  spec.require_paths = %w{ lib }

  spec.add_runtime_dependency 'cocoapods', '0.26.0'
  spec.add_runtime_dependency 'thor', '~> 0.18.1'
  spec.add_runtime_dependency 'xcodeproj', '~> 0.14.1'

  spec.required_ruby_version = '>= 1.8.7'
end
