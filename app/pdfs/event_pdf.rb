class EventPdf < Prawn::Document
	# Initializes the document
	def initialize(event, view)
		super()
		@event = event
		@view = view
		display_header
		display_table
	end

	# Header information
	def display_header

		data = [ [ @event.title ], 
				 [ "Organized by: " + User.find_by_id(@event.organizer_id).name ],
				 [ privacy_setting ],
				 [ division_setting ],
				 [ "Money due: " + @event.due_at_time + ", " + @event.due_at_date ] ]

		table([ { :image => event_image }, data ])
	end

	# Table information
	def display_table
		#list table of members
	end

	# Returns text of private or public event
	def privacy_setting
		(@event.private? ? "Private " : "Public ") + "Event"
	end

	# Determines how event was divided and prints amount
	def division_setting
		if @event.divide_total?
			"Split total: #{price_cents(@event.total_amount_cents)}"
		elsif @event.divide_per_person?
			"Amount per person: #{price_cents(@event.split_amount_cents)}"
		elsif @event.fundraiser?
			"Fundraiser goal: " + "GOAL_HERE"
		end
	end

	# Turns price in cents to money value in dollars
	def price_cents(val)
		price(val/100)
	end

	# Turns price to dollars
	def price(val)
		@view.number_to_currency(val)
	end

	# Returns image path as string
	def event_image

		img_str = "#{Rails.root}/app/assets/images/"

		if @event.image_type == :upload
			img_str + @event.image_file_name
		elsif @event.image_type == :url
			img_str + @event.image_url
		elsif @event.image_type == :default_image
			img_str + "default_event_image.png"
		end
	end
end