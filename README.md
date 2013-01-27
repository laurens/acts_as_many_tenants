# Acts As Many Tenants

Based on [acts_as_tenant](http://github.com/ErwinM/acts_as_tenant) this gem allows for a model to belong to many tenants.

`acts_as_many_tenants` sets up a `has_and_belongs_to_many` relationship to a tenant model and introduces a `default_scope` that checks for the existence of an association to `ActsAsTenant.current_tenant`.

Note that in contrast to `acts_as_tenant`, `acts_as_many_tenants` does not automatically assign the current tenant to newly created objects.

## Usage

Add the following line to your model

``acts_as_many_tenants``

You can specify the name of the tenant model as an attribute (defaults to `Account`).

``acts_as_many_tenants(:accounts)``

You can also use a has_many :through relation for tenants. 
For example a `Task` may belong to a `Project` and relate to many accounts through its project:

``acts_as_many_tenants(:accounts, :through => :project)``

Pass `:required => true` in order to validate the presence of an associated tenant.

``acts_as_many_tenants(:accounts, :required => true)``

## Installation

Add the following line to your Gemfile

``gem 'acts_as_many_tenants', :git => 'git://github.com/laurens/acts_as_many_tenants.git'``

and run

``bundle install``

## TODO

- Make associations immutable (in order to align with `acts_as_tenant`)
