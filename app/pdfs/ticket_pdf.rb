class TicketPdf < Prawn::Document

	# Initializes the document
	def initialize(event, view)
		super()
		@event = event
		@view = view

		generate_and_display_image
	end

	# Displays image
	def generate_and_display_image

		img = RQRCode::QRCode.new("http://www.facebook.com")
		puts img
	end
end