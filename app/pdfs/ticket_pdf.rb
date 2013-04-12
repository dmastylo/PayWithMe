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
	end

	# Draws text based information on left side
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

	# Draw all graphical content on left side
	def draw_graphics

		# Draws event image on ticket
		image event_image, at: [280, 170], fit: [160, 160]

		# Draws small m logo in corner
		image m_image, at: [10, 50], fit: [40, 40]

		# Draws paywith.me text along the bottom
		standard_size = font_size

		font_size 20
		text_box "www.paywith.me", at: [60, 30], height: 40

		font_size standard_size
	end

	# Draws ticket stub, right portion
	def draw_ticket_stub
		image pwm_image, at: [462, 226]
		generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", 690, 30)
	end

	# Displays qr code as grid
	def generate_and_display_qr(link_to_embed, x_start, y_start)

		@qr = RQRCode::QRCode.new(link_to_embed, size: 5)

		x_pos = x_start
		y_pos = y_start
		width = 5

		@qr.modules.each_index do |y|
		 	x_pos -= width
		 	@qr.modules.each_index do |x|
				y_pos += width
	    	if @qr.dark?(x,y)
	    		fill_color "000000"
	    		fill_rectangle [x_pos, y_pos], width, width
	   		else
	   			fill_color "FFFFFF"
	   			fill_rectangle [x_pos ,y_pos], width, width
	   		end
		  end
		  y_pos = y_start
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
		"#{Rails.root}/app/assets/images/logo_black_rotated.png"
	end

	# Return m image path as string
	def m_image
		"#{Rails.root}/app/assets/images/default_event_image.png"
	end
end