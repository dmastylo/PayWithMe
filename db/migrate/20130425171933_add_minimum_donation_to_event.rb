class AddMinimumDonationToEvent < ActiveRecord::Migration
  def change
    add_column :events, :minimum_donation_cents, :integer
  end
end
