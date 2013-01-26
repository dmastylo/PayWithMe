class AddImageFieldsToGroups < ActiveRecord::Migration
  def up
    add_attachment :groups, :image
  end

  def down
    add_attachment :groups, :image
  end
end
