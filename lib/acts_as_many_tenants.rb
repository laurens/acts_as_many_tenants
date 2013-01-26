module ActsAsManyTenants
  extend ActiveSupport::Concern
  
  module ClassMethods
    def acts_as_many_tenants(association = :accounts, options = {})
      options.reverse_merge!({:through => false, :required => false, :immutable => true})
      
      if options[:through]
        has_many association, :through => options[:through]
      else
        has_and_belongs_to_many association
      end

      # get the tenant model and its foreign key
      reflection = reflect_on_association association
# raise reflection.inspect
      fkey = reflection.association_foreign_key

      if options[:immutable]
        raise "TODO immutable association not yet implemented"
      end

      attr_accessible "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids

      if options[:required]
        validates_presence_of "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids
      end

      # set the default_scope to scope to current tenant
      unless options[:through]
        default_scope lambda {
          if ActsAsTenant.current_tenant
            # using EXISTS query here, 
            # not using joins() since that would give us ReadOnly records
            where("EXISTS (SELECT 1 from #{reflection.options[:join_table]} WHERE #{reflection.foreign_key} = #{self.table_name}.id AND #{fkey} = ?)", ActsAsTenant.current_tenant.id)
          end
        }
      else
        raise "TODO default_scope for has_many :through associations"
        default_scope lambda {
          # joins(options[:through]).where(options[:through] => {fkey => ActsAsTenant.current_tenant.id}) if ActsAsTenant.current_tenant
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsManyTenants)
