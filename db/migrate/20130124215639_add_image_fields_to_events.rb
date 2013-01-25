class AddImageFieldsToEvents < ActiveRecord::Migration
  def up
    add_attachment :events, :image
  end

  def down
    add_attachment :events, :image
  end
end
