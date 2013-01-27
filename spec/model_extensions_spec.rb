require 'spec_helper'

# Setup the models
# TODO move those to the dummy app
class Account < ActiveRecord::Base
  attr_accessible :name
end

class Project < ActiveRecord::Base
  attr_accessible :name
  has_many :tasks
  acts_as_many_tenants :accounts
end

class Task < ActiveRecord::Base
  attr_accessible :name
  belongs_to :project
  acts_as_many_tenants :accounts, :through => :project
end

class User < ActiveRecord::Base
  attr_accessible :name
  acts_as_many_tenants :accounts, :immutable => false
end

class Bill < ActiveRecord::Base
  attr_accessible :name
  acts_as_many_tenants :accounts, :required => true
end


# Start testing!
describe ActsAsManyTenants do
  after { ActsAsTenant.current_tenant = nil }
  
  describe 'Project.all should be scoped to the current tenant if set' do
    before do
      @account1 = Account.create!(:name => 'foo')
      @account2 = Account.create!(:name => 'bar')
      @account3 = Account.create!(:name => 'baz')

      @project1 = Project.new(:name => 'foo')
      @project1.accounts = [@account1, @account2]
      @project1.save!
      
      @project2 = Project.new(:name => 'bar')
      @project2.accounts = [@account1]
      @project2.save!

      @project3 = Project.new(:name => 'baz')
      @project3.accounts = [@account3]
      @project3.save!
      
      ActsAsTenant.current_tenant= @account1
      @projects = Project.all
    end
    
    it { @projects.length.should == 2 }
    it { @projects.should == [@project1, @project2] }
  end
  
  describe 'Project.unscoped.all should return the unscoped value' do
    before do
      @account1 = Account.create!(:name => 'foo')
      @account2 = Account.create!(:name => 'bar')
      @account3 = Account.create!(:name => 'baz')

      @project1 = Project.new(:name => 'foo')
      @project1.accounts = [@account1, @account2]
      @project1.save!
      
      @project2 = Project.new(:name => 'bar')
      @project2.accounts = [@account1]
      @project2.save!

      @project3 = Project.new(:name => 'baz')
      @project3.accounts = [@account3]
      @project3.save!
      
      ActsAsTenant.current_tenant= @account1
      @projects = Project.unscoped.all
    end
    
    it { @projects.length.should == 3 }
  end
  
  describe 'Task.all should be scoped to the current tenant through Project' do
    before do
      @account1 = Account.create!(:name => 'foo')
      @account2 = Account.create!(:name => 'bar')
      @account3 = Account.create!(:name => 'baz')

      @project1 = Project.new(:name => 'foo')
      @project1.accounts = [@account1, @account2]
      @project1.save!
      
      @project2 = Project.new(:name => 'bar')
      @project2.accounts = [@account3]
      @project2.save!
      
      @task1 = Task.new(:name => 'foo')
      @task1.project = @project1
      @task1.save!

      @task2 = Task.new(:name => 'bar')
      @task2.project = @project1
      @task2.save!

      @task3 = Task.new(:name => 'baz')
      @task3.project = @project2
      @task3.save!

      ActsAsTenant.current_tenant= @account1
      @tasks = Task.all
    end
    
    it { @tasks.length.should == 2 }
    it { @tasks.should == [@task1, @task2] }
  end

  
  # describe 'Associations should be correctly scoped by current tenant' do
  #   before do
  #     @account = Account.create!(:name => 'foo')
  #     @project = @account.projects.create!(:name => 'foobar', :account_id => @account.id )
  #     # the next line would normally be nearly impossible: a task assigned to a tenant project, 
  #     # but the task has no tenant assigned
  #     @task1 = Task.create!(:name => 'no_tenant', :project => @project) 
  #     
  #     ActsAsTenant.current_tenant = @account
  #     @task2 = @project.tasks.create!(:name => 'baz')
  #     @tasks = @project.tasks
  #   end
  #   
  #   it 'should correctly set the tenant on the task created with current_tenant set' do
  #     @task2.account.should == @account
  #   end
  #   
  #   it 'should filter out the non-tenant task from the project' do
  #     @tasks.length.should == 1
  #   end
  # end
  # 
  # describe 'When dealing with a user defined default_scope' do
  #   before do
  #     @account = Account.create!(:name => 'foo')
  #     @project1 = Project.create!(:name => 'inaccessible')
  #     @task1 = Task.create!(:name => 'no_tenant', :project => @project1)
  #     
  #     ActsAsTenant.current_tenant = @account
  #     @project2 = Project.create!(:name => 'accessible')
  #     @task2 = @project2.tasks.create!(:name => 'bar')
  #     @task3 = @project2.tasks.create!(:name => 'baz')
  #     @task4 = @project2.tasks.create!(:name => 'foo')
  #     @task5 = @project2.tasks.create!(:name => 'foobar', :completed => true )
  #     
  #     @tasks= Task.all
  #   end
  #   
  #   it 'should apply both the tenant scope and the user defined default_scope, including :order' do
  #     @tasks.length.should == 3 
  #     @tasks.should == [@task2, @task3, @task4] 
  #   end
  # end
  
  describe "new projects should be automatically assigned to the current_tenant" do
    
  end
  
  describe "projects should not validate presence of a tenant" do
    before do
      @project1 = Project.new(:name => 'foobar')
    end
    
    it { @project1.should be_valid  }
  end

  describe "bills should validate presence of a tenant" do
    before do
      @bill1 = Bill.new(:name => 'foobar')
    end
    
    it do
      @bill1.valid?
      @bill1.errors[:account_ids].should == ["can't be blank"]
    end
  end

  describe 'project tenants should be immutable' do
    before do
      @account1 = Account.create!(:name => 'foo')
      @account2 = Account.create!(:name => 'bar')

      @project1 = Project.new(:name => 'foo')
      @project1.accounts = [@account1]
    end
    
    it { lambda { @project1.accounts << @account2 }.should raise_error }
  end

  describe 'user tenants should not be immutable' do
    before do
      @account1 = Account.create!(:name => 'foo')
      @account2 = Account.create!(:name => 'bar')

      @user1 = User.new(:name => 'foo')
      @user1.accounts = [@account1]
    end
    
    it { lambda { @user1.accounts << @account2 }.should_not raise_error }
  end
  
  # TÓDO rewrite the following tests from acts_as_tenant for acts_as_many_tenants
  
  # describe 'Associations can only be made with in-scope objects' do
  #   before do
  #     @account = Account.create!(:name => 'foo')
  #     @project1 = Project.create!(:name => 'inaccessible_project', :account_id => @account.id + 1)
  #     
  #     ActsAsTenant.current_tenant = @account
  #     @project2 = Project.create!(:name => 'accessible_project')
  #     @task = @project2.tasks.create!(:name => 'bar')
  #   end
  # 
  #   it { @task.update_attributes(:project_id => @project1.id).should == false }
  # end
  # 
  # describe 'When using validates_uniqueness_to_tenant in a aat model' do
  #   before do
  #     @account = Account.create!(:name => 'foo')
  #     ActsAsTenant.current_tenant = @account
  #     @project1 = Project.create!(:name => 'bar')
  #   end
  #   
  #   it 'should not be possible to create a duplicate within the same tenant' do
  #     @project2 = Project.create(:name => 'bar').valid?.should == false
  #   end
  #   
  #   it 'should be possible to create a duplicate outside the tenant scope' do
  #     @account = Account.create!(:name => 'baz')
  #     ActsAsTenant.current_tenant = @account
  #     @project2 = Project.create(:name => 'bar').valid?.should == true
  #   end
  # end
  # 
  # describe 'When using validates_uniqueness_of in a NON-aat model' do
  #   before do
  #     @city1 = City.create!(:name => 'foo')
  #   end
  #   it 'should not be possible to create duplicates' do
  #     @city2 = City.create(:name => 'foo').valid?.should == false
  #   end
  # end
  # 
  # describe "It should be possible to use aliased associations" do
  #   it { @sub_task = SubTask.create(:name => 'foo').valid?.should == true }
  # end
  # 
  # describe "It should be possible to create and save an AaT-enabled child without it having a parent" do
  #     @account = Account.create!(:name => 'baz')
  #     ActsAsTenant.current_tenant = @account
  #     Task.create(:name => 'bar').valid?.should == true
  # end
  # 
  # describe "It should be possible to use direct many-to-many associations" do
  #     @manager = Manager.create!(:name => 'fool')
  #     @manager.tools.new(:name => 'golden hammer')
  #     @manager.save.should == true
  # end
  # 
  # describe "It should be possible to use direct many-to-many associations" do
  #   @manager = Manager.create!(:name => 'fool')
  #   @manager.tools.new(:name => 'golden hammer')
  #   @manager.save.should == true
  # end
  # 
  # describe "When using direct many-to-many associations they are correctly scoped to the tenant" do
  #   before do
  #     @account1 = Account.create!(:name => 'foo')
  #     @account2 = Account.create!(:name => 'bar')
  # 
  #     ActsAsTenant.current_tenant= @account1
  #     @manager1 = Manager.create!(:name => 'fool')
  #     @tool1 = @manager1.tools.create!(:name => 'golden hammer')
  # 
  #     ActsAsTenant.current_tenant= @account2
  #     @manager2 = Manager.create!(:name => 'pitty')
  #     @tool2 = @manager2.tools.create!(:name => 'golden saw')
  # 
  #     @tools = Tool.all
  #   end
  #   it { @tools.should == [@tool2] }
  # end
end
