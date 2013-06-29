class RenameUserIdToAccountIdOnCards < ActiveRecord::Migration
  def change
    rename_column :cards, :user_id, :account_id
  end
end
