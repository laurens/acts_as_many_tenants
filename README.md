# Acts As Many Tenants

Based on [acts_as_tenant](http://github.com/ErwinM/acts_as_tenant) this gem allows for a model to belong to many tenants.

- `acts_as_many_tenants` sets up `has_and_belongs_to_many` relationship to the tenant model
- Introduces a default scope that checks for the existence of a relationship with `ActsAsTenant.current_tenant`
- The default scope is defined using a `WHERE EXISTS ()` query. 
- `acts_as_many_tenants` validates presence of at least one tenant.

## Installation

``gem 'acts_as_many_tenants', :git => 'git://github.com/laurens/acts_as_many_tenants.git'``

## Usage

Add this to your model

``acts_as_many_tenants(:account)``

## TODO

This gem is still under development.

- Write tests
- Set default to current_tenant when creating new records (optional, in order to align with `acts_as_tenant`)
- Introduce option to make associations immutable (in order to align with `acts_as_tenant`)
- Make validation of presence optional (in order to align with `acts_as_tenant`)
- Make this work with `has_many :through` associations
