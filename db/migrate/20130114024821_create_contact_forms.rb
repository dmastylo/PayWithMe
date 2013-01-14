class CreateContactForms < ActiveRecord::Migration
  def change
    create_table :contact_forms do |t|

      t.timestamps
    end
  end
end
