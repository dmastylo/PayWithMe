class AddTypeColumnsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :division_type, :int
    add_column :events, :fee_type, :int
  end
end
