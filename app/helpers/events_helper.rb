module EventsHelper
	def event_image_path(event, size=:thumb)
	  if event.event_image.present?
	    event.event_image.url(size)
	  elsif event.event_image_url.present?
	    event.event_image_url
	  end
	end

	def event_image_tag(event, size=:thumb)
	  width = Figaro.env.send(size.to_s+"_size")
	  if event.event_image.present? || event.event_image_url.present?
	    image = image_tag(event_image_path(event, size), width: width)
	  else
	    image = image_tag("default_event_image.png", width: width)
	  end
	  link_to image, event
	end
end