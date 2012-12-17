class AddPrivacyTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :privacy_type, :int
  end
end
