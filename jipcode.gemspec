
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jipcode/version"

Gem::Specification.new do |spec|
  spec.name          = "jipcode"
  spec.version       = Jipcode::VERSION
  spec.authors       = ["rinkei"]
  spec.email         = ["kei.h.hayashi@gmail.com"]

  spec.summary       = %q{jipcode is a gem of Japanese zipcode search.}
  spec.description   = %q{This supports Japan Post's official zipcode update.}
  spec.homepage      = "https://github.com/rinkei/jipcode"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
