class AddImageFieldsToEvents < ActiveRecord::Migration
  def change
    add_attachment :events, :image
  end
end
