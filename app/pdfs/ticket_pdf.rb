class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event, event_user)
		super(:page_layout => :landscape)
		@event = event
		@event_user = event_user

		# Draws border
		rectangle [0, 250], 700, 250
		stroke_vertical_line 0, 250, at: 450

		draw_information
		draw_graphics
		draw_ticket_stub

		# info_table = make_table(fill_in_information, cell_style: { borders: [], overflow: :expand, inline_format: true, padding_left: 5, padding_right: 5, width: 200 })
		# left_side = [[ info_table, {image: event_image, fit: [150, 150], vposition: :center, padding_left: 5, padding_top: 15, padding_right: 5, height: 200 } ]]

		# ticket_table = make_table(fill_in_ticket, cell_style: { borders: [], overflow: :expand, inline_format: true, rotate: 90 })

		# full_data = [[left_side, ticket_table]]
		# table full_data, cell_style: { borders: [] }

		#generate_and_display_qr('http://www.paywith.me/paid', 200, 300)
	end

	def draw_information
		standard_size = font_size
		x_pos = 10
		y_pos = 240

		font_size 10
		text_box "Your ticket to:", at: [x_pos, y_pos]

		font_size 24
		text_box "#{@event.title}", style: :bold, at: [x_pos, y_pos - 25], width: 430, overflow: :truncate

		font_size standard_size
		text_box "Name: #{@event_user.user.name || @event_user.user.email}", at: [x_pos, y_pos - 60], width: 240
		text_box "Payment Method: #{@event_user.payments[0].payment_method.name}", at: [x_pos, y_pos - 80], width: 240
		text_box "Date Paid: #{@event_user.paid_at}", at: [x_pos, y_pos - 100], width: 240
		text_box "Event Details: #{@event.description}", at: [x_pos, y_pos - 120], width: 240, height: 70, overflow: :truncate
	end

	def draw_graphics

		# Draws event image on ticket
		image event_image, at: [280, 170], fit: [160, 160]

		# Draws small m logo in corner

		#if @event.image_type != :default_image
			image m_image, at: [10, 50], fit: [40, 40]
		#end

		standard_size = font_size

		font_size 20
		text_box "www.paywith.me", at: [60, 30], height: 40

		font_size standard_size

	end

	def draw_ticket_stub

	end

	# Fills in information, the left side of the ticket
	def fill_in_information
		[
			["<font size='10'>Your ticket to:</font>"],
			["<font size='24'><b>#{@event.title}</b></font>"],
			["Name: #{@event_user.user.name || @event_user.user.email}"],
			["Payment Method: #{@event_user.payments[0].payment_method.name}"],
			["Date Paid: #{@event_user.paid_at}"],
			["Event Details: #{@event.description}"]
		]
	end

	# Fills in ticket, the right side of the ticket
	def fill_in_ticket
		[
			["Test info"],
			["Testing"]
		]
	end

	# Displays qr code as grid
	def generate_and_display_qr(link_to_embed, x_start, y_start)

		@qr = RQRCode::QRCode.new(link_to_embed)

		x_pos = x_start
		y_pos = y_start
		width = 5

		@qr.modules.each_index do |x|
		 	y_pos -= width
		 	@qr.modules.each_index do |y|
				x_pos += width
		    	if @qr.dark?(x,y)
		    		fill_color "000000"
		    		fill_rectangle [x_pos, y_pos], width, width
		   		else
		   			fill_color "FFFFFF"
		   			fill_rectangle [x_pos ,y_pos], width, width
		   		end
		   	end
		   	x_pos = x_start
		end
	end

	# Returns image path as string
	def event_image
	  if @event.image_type == :upload
	    open(@event.image.url)
	  elsif @event.image_type == :url
	    open(@event.image_url)
	  elsif @event.image_type == :default_image
	    "#{Rails.root}/app/assets/images/default_event_image.png"
	  end
	end

	# Return paywithme image path as string
	def pwm_image
		"#{Rails.root}/app/assets/images/logo_black.png"
	end

	# Return m image path as string
	def m_image
		"#{Rails.root}/app/assets/images/default_event_image.png"
	end
end