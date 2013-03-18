class EventPdf < Prawn::Document
	def initialize(event, view)
		super()
		@event = event
		@view = view
		display_header
		display_table
	end

	def display_header
		#image on left
		#information coming from it
	end

	def display_table
		#list table of members
	end
end