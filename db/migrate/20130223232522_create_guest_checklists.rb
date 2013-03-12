class CreateGuestChecklists < ActiveRecord::Migration
  def change
    create_table :guest_checklists do |t|

      t.timestamps
    end
  end
end
