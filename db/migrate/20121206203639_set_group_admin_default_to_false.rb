class SetGroupAdminDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :group_users, :admin, false
  end
end
