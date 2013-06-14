class AddAccountIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :account_id, :integer
    add_column :cards, :brand, :string
    add_column :cards, :expiration_month, :integer
    add_column :cards, :expiration_year, :integer
  end
end
