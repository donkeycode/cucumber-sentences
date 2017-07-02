$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'cucumber-sentences'
  s.version     = '0.0.7'
  s.license     = 'MIT'
  s.summary     = "Pre-built sentences for your cucumber tests"
  s.description = "Pre-built sentences for your cucumber tests"
  s.authors     = ["DonkeyCode", "Cedric LOMBARDOT"]
  s.email       = 'cedric@donkeycode.com'
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(pkg|spec|features|coverage)/}) }
  s.require_paths = ["lib"]
  s.homepage    = 'https://rubygems.org/gems/cucumber-sentences'
end
