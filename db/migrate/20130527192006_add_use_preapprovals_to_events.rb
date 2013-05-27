class AddUsePreapprovalsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :use_preapprovals, :boolean, default: false
  end
end
