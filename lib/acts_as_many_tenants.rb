module ActsAsManyTenants
  extend ActiveSupport::Concern
  
  module ClassMethods
    def acts_as_many_tenants(association = :accounts, through_association = false)
      unless through_association
        has_and_belongs_to_many association
      else
        belongs_to through_association
        has_many association, :through => through_association
      end

      # get the tenant model and its foreign key
      reflection = reflect_on_association association

      fkey = reflection.association_foreign_key

      # TODO make attr_accessible optional, otherwise make immutable
      attr_accessible "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids

      # validate presence
      # TODO make optional
      validates_presence_of "#{association.to_s.singularize}_ids".to_sym # e.g. account_ids

      # set the default_scope to scope to current tenant
      unless through_association
        default_scope lambda {
          # using EXISTS query here, 
          # using joins() ActiveRecord returns ReadOnly records
          where("EXISTS (select 1 from #{reflection.options[:join_table]} where #{reflection.foreign_key} = #{self.table_name}.id AND #{fkey} = ?)", ActsAsTenant.current_tenant.id) if ActsAsTenant.current_tenant
          # joins(association).where(association => {:id => ActsAsTenant.current_tenant.id}) if ActsAsTenant.current_tenant
        }
      else
        raise "TODO  acts_as_many_tenants: default_scope for through_association"
        default_scope lambda {
          # joins(through_association).where(through_association => {fkey => ActsAsTenant.current_tenant.id}) if ActsAsTenant.current_tenant
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsManyTenants)
