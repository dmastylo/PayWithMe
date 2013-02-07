class AddStubDataFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :creator_id, :integer
    add_column :users, :completed_at, :datetime
  end
end
