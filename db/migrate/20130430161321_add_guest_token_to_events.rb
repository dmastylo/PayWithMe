class AddGuestTokenToEvents < ActiveRecord::Migration
  def change
    add_column :events, :guest_token, :string
  end
end
