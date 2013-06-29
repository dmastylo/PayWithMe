class AddDebitUriToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :debit_uri, :string
  end
end
