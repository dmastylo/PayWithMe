class ChangeCampusRepName < ActiveRecord::Migration
  def change
    rename_table :campus_reps, :affiliates
  end 
end
