module EventsHelper
	def event_image_path(event, size=:thumb)
	  if event.image.present?
	    event.image.url(size)
	  elsif event.image_url.present?
	    event.image_url
	  else
	  	asset_path("default_event_image.png")
	  end
	end

	def event_image_tag(event, size=:thumb)
	  width = Figaro.env.send(size.to_s+"_size")
	  image = image_tag(event_image_path(event, size), width: width)
	  link_to image, event
	end
end