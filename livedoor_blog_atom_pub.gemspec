# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'livedoor_blog_atom_pub/version'

Gem::Specification.new do |spec|
  spec.name          = "livedoor_blog_atom_pub"
  spec.version       = LivedoorBlogAtomPub::VERSION
  spec.authors       = ["YuheiNakasaka"]
  spec.email         = ["yuhei.nakasaka@gmail.com"]

  spec.summary       = %q{client library for livedoor blog atom pub api}
  spec.homepage      = "https://github.com/YuheiNakasaka/livedoor-blog-atom-pub-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "webmock"
  spec.add_dependency "wsse"
end
