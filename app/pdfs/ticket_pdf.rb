class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event)
		super()
		@event = event

		generate_and_display_qr('http://www.paywith.me/paid', 200, 300)

		text "Success"
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