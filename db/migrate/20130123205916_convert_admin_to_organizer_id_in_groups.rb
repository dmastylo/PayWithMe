class ConvertAdminToOrganizerIdInGroups < ActiveRecord::Migration
  def up
    GroupUser.where(admin: true).all.each do |group_user|
      group_user.group.organizer_id = group_user.user_id
      group_user.group.save
    end

    remove_column :group_users, :admin
  end

  def down
    add_column :group_users, :admin, :boolean

    Group.all.each do |group|
      group_user = GroupUser.where(group_id: group.id, user_id: group.organizer_id)
      group_user.admin = true
      group_user.save
    end
  end
end
