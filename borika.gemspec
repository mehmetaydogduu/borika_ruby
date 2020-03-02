# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'borika/version'

Gem::Specification.new do |spec|
  spec.name          = "borika"
  spec.version       = Borika::VERSION
  spec.authors       = ["Mehmet Aydoğdu"]
  spec.email         = ["mhmt.dp@gmail.com"]
  spec.date          = "2020-03-02"
  spec.summary       = "Borika Bank payment gem for Ruby."
  spec.description   = "Borika gem for Ruby."
  spec.homepage      = "https://github.com/fastengineer/borika_ruby"
  spec.license       = "GPL"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
