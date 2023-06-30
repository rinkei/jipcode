
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jipcode/version"

Gem::Specification.new do |spec|
  spec.name          = "jipcode"
  spec.version       = Jipcode::VERSION
  spec.authors       = ["rinkei"]
  spec.email         = ["kei.h.hayashi@gmail.com"]

  spec.summary       = %q{A gem for Japan Post's official zipcode data search & update.}
  spec.description   = %q{A gem for Japan Post's official zipcode data search & update.}
  spec.homepage      = "https://github.com/rinkei/jipcode"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.4.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'rubyzip'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'bump'
end
