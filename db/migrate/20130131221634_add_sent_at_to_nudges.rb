class AddSentAtToNudges < ActiveRecord::Migration
  def change
    add_column :nudges, :sent_at, :datetime
  end
end
