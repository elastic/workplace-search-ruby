$:.push File.expand_path("../lib", __FILE__)
require "swiftype-enterprise/version"

Gem::Specification.new do |s|
  s.name        = "swiftype-enterprise"
  s.version     = SwiftypeEnterprise::VERSION
  s.authors     = ["Quin Hoxie"]
  s.email       = ["support@swiftype.com"]
  s.homepage    = "https://swiftype.com"
  s.summary     = %q{Deprecated gem for accessing the Swiftype Enterprise Search API. Use elastic-enterprise-search instead.}
  s.description = %q{API client for accessing the Swiftype Enterprise API with no dependencies.}
  s.post_install_message = "DEPRECATION WARNING: The swiftype-enterprise gem has been deprecated and replaced by elastic-enterprise-search"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'vcr', '~> 3.0.3'
  s.add_development_dependency 'webmock'
end
