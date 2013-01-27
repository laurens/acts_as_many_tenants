module ActsAsManyTenants
  extend ActiveSupport::Concern
  
  module ClassMethods
    def acts_as_many_tenants(association = :accounts, options = {})
      options.reverse_merge!({:through => false, :required => false, :immutable => true})
      
      if options[:through]
        has_many association, :through => options[:through]
        # namespaced Model constant: foo/bar_baz -> Foo::BarBaz
        reflection = options[:through].to_s.camelize.constantize.reflect_on_association(association)
        # foo/bar_baz -> Foo::BarBaz -> BarBaz -> bar_baz -> :bar_baz
        through_reflection = reflect_on_association(options[:through].to_s.camelize.demodulize.underscore.to_sym)
      else
        has_and_belongs_to_many association
        reflection = reflect_on_association(association)
      end

      if options[:immutable]
        Rails.logger.info "TODO immutable association not yet implemented"
      end

      attr_accessible "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids

      if options[:required]
        validates_presence_of "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids
      end

      # set the default_scope to scope to current tenant
      # using EXISTS queries here, 
      # not using joins() since that would give us ReadOnly records
      unless options[:through]
        default_scope lambda {
          if ActsAsTenant.current_tenant
            where("EXISTS (SELECT 1 FROM #{reflection.options[:join_table]} WHERE #{reflection.options[:join_table]}.#{reflection.foreign_key} = #{self.table_name}.id AND #{reflection.options[:join_table]}.#{reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
          end
        }
      else
        default_scope lambda {
          if ActsAsTenant.current_tenant
            where("EXISTS (SELECT 1 FROM #{reflection.options[:join_table]} WHERE #{reflection.options[:join_table]}.#{reflection.foreign_key} = #{self.table_name}.#{through_reflection.foreign_key} AND #{reflection.options[:join_table]}.#{reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
          end
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsManyTenants)
