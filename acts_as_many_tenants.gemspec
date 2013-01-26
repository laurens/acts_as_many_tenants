$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_many_tenants/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_many_tenants"
  s.version     = ActsAsManyTenants::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ActsAsManyTenants."
  s.description = "TODO: Description of ActsAsManyTenants."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "acts_as_tenant"

  s.add_development_dependency "sqlite3"
end
