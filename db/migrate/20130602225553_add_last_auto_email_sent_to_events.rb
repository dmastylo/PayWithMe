class AddLastAutoEmailSentToEvents < ActiveRecord::Migration
  def change
    add_column :events, :last_auto_email_sent, :datetime
    add_column :events, :last_daily_email_sent, :datetime
  end
end
