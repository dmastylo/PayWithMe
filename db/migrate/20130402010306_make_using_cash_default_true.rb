class MakeUsingCashDefaultTrue < ActiveRecord::Migration
  def change
    change_column :users, :using_cash, :boolean, default: false
    User.update_all(using_cash: false)
  end
end
