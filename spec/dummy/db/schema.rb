ActiveRecord::Schema.define(:version => 2) do
  create_table :accounts, :force => true do |t|
    t.column :name, :string
  end

  create_table :projects, :force => true do |t|
    t.column :name, :string
  end

  create_table :accounts_projects, :id => false do |t|
    t.references :account
    t.references :project
  end
  
  create_table :tasks, :force => true do |t|
    t.column :name, :string
    t.references :project
  end

  create_table :users, :force => true do |t|
    t.column :name, :string
  end

  create_table :accounts_users, :id => false do |t|
    t.references :account
    t.references :user
  end

  create_table :bills, :force => true do |t|
    t.column :name, :string
  end

  create_table :accounts_bills, :id => false do |t|
    t.references :account
    t.references :bill
  end

  create_table :things, :force => true do |t|
    t.column :name, :string
  end

  create_table :accounts_things, :id => false do |t|
    t.references :account
    t.references :thing
  end
  
end
