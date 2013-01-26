# Acts As Many Tenants

Based on [acts_as_tenant](http://github.com/ErwinM/acts_as_tenant) this gem allows for a model to belong to many tenants.

`acts_as_many_tenants` sets up a `has_and_belongs_to_many` relationship to a tenant model.

It introduces a `default_scope` that checks for the existence of an association to `ActsAsTenant.current_tenant`.

## Installation

Add the following line to your Gemfile

``gem 'acts_as_many_tenants', :git => 'git://github.com/laurens/acts_as_many_tenants.git'``

and run

``bundle install``

## Usage

Add the following line to your model

``acts_as_many_tenants``

You can specify the name of the tenant model as an attribute (defaults to `Account`).

``acts_as_many_tenants(:account)``

Pass `:required => true` in order to validae the presence of an associated tenant.

``acts_as_many_tenants(:account, :required => true)``

## TODO

This gem is still under development.

- Write tests
- Set default to current_tenant when creating new records (in order to align with `acts_as_tenant`)
- Make associations immutable (in order to align with `acts_as_tenant`)
- Make this work with `has_many :through` associations
