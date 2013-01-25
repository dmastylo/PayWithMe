module GroupsHelper
  def group_for_mustache(group)
    {
      id: group.id,
      title: group.title
    }
  end

    def group_image_path(group, size=:thumb)
    	if group.image.present?
    		group.image.url(size)
    	elsif group.image_url.present?
    		group.image_url
    	else
    		asset_path("default_group_image.png")
    	end
    end

    def group_image_tag(group, size=:thumb)
    	width = Figaro.env.send(size.to_s+"_size")
    	image = image_tag(group_image_path(group, size), width: width)
    	link_to image, group
    end
end