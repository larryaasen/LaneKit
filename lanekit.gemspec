# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanekit/version'

Gem::Specification.new do |spec|
  spec.name          = "lanekit"
  spec.version       = LaneKit::VERSION
  spec.authors       = ["Larry Aasen"]
  spec.email         = ["larryaasen@gmail.com"]
  spec.description   = %q{a code generator for iOS Objective-C models for integration with RestKit.}
  spec.summary       = %q{LaneKit is a code generator for iOS Objective-C models for integration with RestKit.}
  spec.homepage      = "https://github.com/LarryAasen/LaneKit"
  spec.license       = "MIT"
  
  spec.files = Dir["lib/**/*.rb"] + Dir["lib/**/*.erb"] + %w{ bin/lanekit README.md LICENSE }

  spec.executables   = %w{ lanekit }
  spec.require_paths = %w{ lib }

  spec.add_runtime_dependency 'thor', '~> 0.18.1'
  spec.add_runtime_dependency 'xcodeproj', '~> 0.5.5'

  spec.required_ruby_version = '>= 1.8.7'
end
