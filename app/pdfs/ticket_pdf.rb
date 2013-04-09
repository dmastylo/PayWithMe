class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event, event_user)
		super(:page_layout => :landscape)
		@event = event
		@event_user = event_user

		font_families.update(
		  "Lato" => {
		    bold: "#{Rails.root}/app/assets/fonts/Lato-Bold.ttf",
		    normal: "#{Rails.root}/app/assets/fonts/Lato-Regular.ttf"
		  }
		)

		font("Lato")

		info_table = make_table(fill_in_information, cell_style: { borders: [], overflow: :expand, inline_format: true, padding_left: 5, padding_right: 5 })
		left_side = [[ info_table, {image: event_image, fit: [150, 150], vposition: :center, padding_left: 5, padding_top: 20 } ]]

		ticket_table = make_table(fill_in_ticket, cell_style: { borders: [], overflow: :expand, inline_format: true })

		full_data = [[left_side, ticket_table]]
		table full_data

		#generate_and_display_qr('http://www.paywith.me/paid', 200, 300)
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
end