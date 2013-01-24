module GroupsHelper
  def group_for_mustache(group)
    {
      id: group.id,
      title: group.title
    }
  end
end