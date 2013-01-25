class RemoveEventImageColumnsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :event_image_file_name
    remove_column :events, :event_image_content_type
    remove_column :events, :event_image_file_size
    remove_column :events, :event_image_url
  end

  def down
    add_column :events, :event_image_url, :string
    add_column :events, :event_image_file_size, :integer
    add_column :events, :event_image_content_type, :string
    add_column :events, :event_image_file_name, :string
  end
end
