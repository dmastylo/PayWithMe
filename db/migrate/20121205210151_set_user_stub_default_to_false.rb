class SetUserStubDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :users, :stub, false
  end
end
