class AddImageFieldsToGroups < ActiveRecord::Migration
  def change
    add_attachment :groups, :image
  end
end
