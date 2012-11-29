class AddDivisionToEvent < ActiveRecord::Migration
  def change
    add_column :events, :division, :string
  end
end
