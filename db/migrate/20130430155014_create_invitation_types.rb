class CreateInvitationTypes < ActiveRecord::Migration
  def change
    create_table :invitation_types do |t|
      t.integer :invitation_type
      t.integer :event_id

      t.timestamps
    end
  end
end
