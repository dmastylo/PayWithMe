class AddSendEmailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_emails, :boolean, default: true
  end
end
