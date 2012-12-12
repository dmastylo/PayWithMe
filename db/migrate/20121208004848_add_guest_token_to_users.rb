class AddGuestTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guest_token, :string
  end
end
