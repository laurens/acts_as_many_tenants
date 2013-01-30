$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_many_tenants/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_many_tenants"
  s.version     = ActsAsManyTenants::VERSION
  s.authors     = ["Laurens Nienhaus"]
  s.email       = ["l.nienhaus@gmail.com"]
  s.homepage    = "http://asdfasdf.de"
  s.summary     = "Many to many relationships for acts_as_tenant"
  s.description = "Based on the acts_as_tenant gem, this gem allows for a model to belong to many tenants."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "acts_as_tenant"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
end
