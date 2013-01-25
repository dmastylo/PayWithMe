class AddPicturesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_image_file_name, :string
    add_column :events, :event_image_content_type, :string
    add_column :events, :event_image_file_size, :integer
    add_column :events, :event_image_url, :string
  end
end
