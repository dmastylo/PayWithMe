class AddOrganizerIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :organizer_id, :integer
  end
end
