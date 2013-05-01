class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event, event_user)
		super(:page_layout => :landscape)

		# Set font
		font_families.update(
		  "Lato" => {
		    bold: "#{Rails.root}/app/assets/fonts/Lato-Bold.ttf",
		    normal: "#{Rails.root}/app/assets/fonts/Lato-Regular.ttf"
		  }
		)

		font("Lato")

		# Variable declarations
		@event = event
		@event_user = event_user

		@width = 600
		@height = 200
		@origin = 0
		@stub_start_x = 450

		# draw_ticket
		draw_ticket_2
	end

	def draw_ticket_2
		# Draws border
		rectangle [@origin, @height + @origin], @width, @height

		draw_vertical_dashed_line @stub_start_x

		# Draws left side
		draw_information_2

		# Draws right side
		draw_ticket_stub_2
	end

	def draw_information_2
		# Draws large event image along top
		move_cursor_to @height - 5
		table [[ { image: event_image, fit: [@stub_start_x - 20, @height / 2 - 10],
																	 position: :center,
																	 padding: [0, 0, 0, 20]
					} ]],
					cell_style: { width: @stub_start_x - 20,
								        height: @height / 2 - 10,
								        borders: [] }

		# Draws information below image
		font_size 24
		text_box "#{@event.title}", style: :bold, at: [@origin + 10, @height / 2], width: @stub_start_x - 20, overflow: :shrink_to_fit, align: :center

		# Paid information, via, date, across bottom. Skim date to just show date not time
		font_size 10
		text_box "Admit #{@event_user.user.name || @event_user.user.email}", at: [@origin + 10, 60 ], width: 240

		text_box "paid via #{@event_user.payments[0].payment_method.name}", at: [@origin + 10, 40], width: 240

		text_box "on #{@event_user.paid_at.to_date}", at: [@origin + 10, 20], width: 240
	end

	def draw_ticket_stub_2
		# Draws PayWithMe logo
		image pwm_image, at: [@stub_start_x + 10, 186], fit: [130, 100]

		# Draws some event_user information
		font_size 10
		text_box "#{@event_user.user.name || @event_user.user.email}", at: [@stub_start_x + 10, @height - 60], width: @width - @stub_start_x - 20, align: :center

		# Fix later
		text_box " paid #{@event_user.payments[0].payment_method.name} #{@event_user.paid_total_cents}", at: [@stub_start_x + 10, @height - 70], width: @width - @stub_start_x - 20, align: :center

		# Draws qr code
		generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", @stub_start_x + 33, 10)
	end

	def draw_ticket
		# Draws border
		rectangle [@origin, @height], @width, @height

		draw_vertical_dashed_line @stub_start_x

		# Draws left side
		draw_information

		# Draws right side
		draw_ticket_stub
	end

	# Draws text based information on left side
	def draw_information
		standard_size = font_size
		x_pos = 10
		y_pos = 180
		gap_size = 15

		font_size 10
		text_box "Your ticket to:", at: [x_pos, y_pos]

		y_pos -= gap_size

		# Draws event title
		font_size 24
		text_box "#{@event.title}", style: :bold, at: [x_pos, y_pos], width: 430, overflow: :truncate

		y_pos -= 2*gap_size

		font_size standard_size

		# Draws user name
		text_box "Name: #{@event_user.user.name || @event_user.user.email}", at: [x_pos, y_pos], width: 240
		y_pos -= gap_size

		# Draws payment method
		text_box "Payment Method: #{@event_user.payments[0].payment_method.name}", at: [x_pos, y_pos], width: 240
		y_pos -= gap_size

		# Draws paid at
		text_box "Date Paid: #{@event_user.paid_at}", at: [x_pos, y_pos], width: 240
		y_pos -= gap_size

		# Draws event description
		text_box "Event Details: #{@event.description}", at: [x_pos, y_pos], width: 240, height: 70, overflow: :truncate

		# Draws event image on ticket
		image event_image, at: [280, 170], fit: [160, 160]
	end

	# Draws ticket stub, right portion
	def draw_ticket_stub
		image pwm_image, at: [@stub_start_x + 10, 186], fit: [130, 100]
		generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", @stub_start_x + 5, 15)
	end

	# Displays qr code as grid
	def generate_and_display_qr(link_to_embed, x_start, y_start)

		@qr = RQRCode::QRCode.new(link_to_embed, size: 6)

		x_pos = x_start
		y_pos = y_start
		width = 2

		@qr.modules.each_index do |x|
		 	x_pos += width
		 	@qr.modules.each_index do |y|
				y_pos += width
	    	if @qr.dark?(x,y)
	    		fill_color "000000"
	    		fill_rectangle [x_pos, y_pos], width, width
	   		else
	   			fill_color "FFFFFF"
	   			fill_rectangle [x_pos, y_pos], width, width
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
	    m_image
	  end
	end

	# Return vertical paywithme image path as string
	def pwm_image_rotated
		"#{Rails.root}/app/assets/images/logo_black_rotated.png"
	end

	# Return paywithme image path as string
	def pwm_image
		"#{Rails.root}/app/assets/images/ticket_logo.png"
	end

	# Return m image path as string
	def m_image
		"#{Rails.root}/app/assets/images/default_event_image.png"
	end

	def draw_vertical_dashed_line(x)
		# Value for size of line and space in between
		size = 10

		y = 0

		(@height/(size*2)).times do
			stroke_vertical_line y, y+size, at: x
			y += size*2
		end
	end
end