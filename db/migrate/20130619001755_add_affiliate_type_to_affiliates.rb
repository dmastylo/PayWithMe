class AddAffiliateTypeToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :affiliate_type, :integer
  end
end
