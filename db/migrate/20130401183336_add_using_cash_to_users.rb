class AddUsingCashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :using_cash, :boolean
  end
end
