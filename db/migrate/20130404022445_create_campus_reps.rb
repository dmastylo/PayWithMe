class CreateCampusReps < ActiveRecord::Migration
  def change
    create_table :campus_reps do |t|
      t.string :name
      t.string :school

      t.timestamps
    end
  end
end
