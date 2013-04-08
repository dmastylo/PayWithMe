class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event, event_user)
		super()
		@event = event
		@event_user = event_user

		font_families.update(
		  "Lato" => {
		    bold: "#{Rails.root}/app/assets/fonts/Lato-Bold.ttf",
		    normal: "#{Rails.root}/app/assets/fonts/Lato-Regular.ttf"
		  }
		)

		font("Lato")

		info_table = make_table(fill_in_information, cell_style: { borders: [], overflow: :expand, inline_format: true })
		ticket_table = make_table(fill_in_ticket, cell_style: { borders: [], overflow: :expand, inline_format: true })

		full_data = [[info_table, ticket_table]]

		table full_data, cell_style: { borders: [] }
		#generate_and_display_qr('http://www.paywith.me/paid', 200, 300)
	end

	# Fills in information, the left side of the ticket
	def fill_in_information
		[
			["Your ticket to:"],
			["#{@event.title}"],
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

	# Displays image
	def generate_and_display_qr(link_to_embed, x_start, y_start)

		@qr = RQRCode::QRCode.new(link_to_embed)

		x_pos = x_start
		y_pos = y_start

		@qr.modules.each_index do |x|

		 	y_pos -= 5

		 	@qr.modules.each_index do |y|

				x_pos += 5

		    	if @qr.dark?(x,y)
		    		fill_color "000000"
		    		fill_rectangle [x_pos, y_pos], 5, 5
		   		else
		   			fill_color "FFFFFF"
		   			fill_rectangle [x_pos ,y_pos], 5, 5
		   		end
		   	end

		   	x_pos = x_start

		end
	end
end