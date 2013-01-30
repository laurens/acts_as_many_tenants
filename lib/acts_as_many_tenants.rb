module ActsAsManyTenants
  extend ActiveSupport::Concern
  
  module ClassMethods
    def acts_as_many_tenants(association = :accounts, options = {})
      options.reverse_merge!({:through => false, :required => false, :immutable => true, :auto => true, :class_name => nil})

      if options[:through] && options[:required]
        raise(ArgumentError, ":required cannot be used together with :through [ActsAsManyTenants]") 
      end

      # e.g. account_ids
      singular_ids = "#{association.to_s.singularize}_ids"

      if options[:through]
        has_many association, :through => options[:through], :class_name => options[:class_name]
        reflection = reflect_on_association(association)

        source_reflection = reflection.source_reflection
        through_reflection = reflection.through_reflection
      else
        has_and_belongs_to_many association, :class_name => options[:class_name]
        reflection = reflect_on_association(association)
      end

      if options[:auto]
        before_validation Proc.new { |m|
          return unless ActsAsTenant.current_tenant
          return if m.send(association.to_sym).present?
          m.send "#{association}=".to_sym, [ActsAsTenant.current_tenant]
        }, :on => :create
      end

      if options[:immutable]
        define_method "#{singular_ids}=" do |ids|
          if new_record?
            super(ids) 
          else
            raise "#{association} is immutable! [ActsAsManyTenants]"
          end
        end

        define_method "#{association}=" do |models|
          if new_record?
            super(models)
          else
            raise "#{association} is immutable! [ActsAsManyTenants]"
          end
        end

        # TODO override these methods aswell
        # associations.<<(model), associations.delete(model), associations.clear, associations.build, associations.create
      end

      if options[:required]
        validates_presence_of singular_ids
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
            where("EXISTS (SELECT 1 FROM #{source_reflection.options[:join_table]} WHERE #{source_reflection.options[:join_table]}.#{source_reflection.foreign_key} = #{self.table_name}.#{through_reflection.foreign_key} AND #{source_reflection.options[:join_table]}.#{source_reflection.association_foreign_key} = ?)", ActsAsTenant.current_tenant.id)
          end
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsManyTenants)
