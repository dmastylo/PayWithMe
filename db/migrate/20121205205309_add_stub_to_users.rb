class AddStubToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stub, :boolean
  end
end
