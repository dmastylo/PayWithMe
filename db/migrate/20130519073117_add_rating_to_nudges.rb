class AddRatingToNudges < ActiveRecord::Migration
  def change
    add_column :nudges, :rating, :integer
  end
end
