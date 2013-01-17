class RemoveSlugFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :slug
  end

  def down
    add_column :events, :slug, :string
  end
end
