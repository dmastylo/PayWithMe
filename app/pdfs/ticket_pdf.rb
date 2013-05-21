class TicketPdf < Prawn::Document

  # Initializes the document
  def initialize(event, event_user)
    @options = {
      width: 650,
      height: 200,
      padding: 25,
      stub: 500,
      margin: 0
    }

    super(page_size: [@options[:width], @options[:height]], margin: @options[:margin])

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

    # draw_ticket
    draw_ticket
  end

  def draw_ticket
    
    # Draw background
    self.fill_color "B3E1E9"
    self.fill { rectangle [0, @options[:height]], @options[:width], @options[:height] }

    # Draw border
    self.line_width = 5
    self.stroke_color "000000"
    self.stroke { rectangle [0, @options[:height]], @options[:width], @options[:height] }

    # Draw bordered line
    self.line_width = 2
    self.draw_vertical_dashed_line(@options[:stub])

    # Draw main ticket
    self.fill_color "000000"
    self.image event_image, fit: [180, 150], padding: @options[:padding], at: [@options[:padding], @options[:height] - @options[:padding]]
    
    self.y = @options[:height] - @options[:padding]
    self.text_box @event.title, at: [180, self.y], width: 290, height: 30, align: :center, overflow: :shrink_to_fit, min_font_size: 20, size: 26, style: :bold, valign: :center
    self.y -= 30

    self.text_box "Organized by: #{@event.organizer.name}", at: [180, self.y], align: :center, width: 290, height: 16, size: 14, min_font_size: 12, valign: :center
    self.y -= 30
    
    self.text_box @event.due_at.to_s(:ordinal), at: [180, self.y], width: 290, height: 30, align: :center, overflow: :shrink_to_fit, min_font_size: 20, size: 20, style: :bold, valign: :center
    self.y -= 45

    self.text_box "<b>Attendee:</b> #{UsersController.helpers.user_name(@event_user.user)}", at: [180, self.y], width: 290, align: :center, inline_format: true, height: 16, size: 14, min_font_size: 12, valign: :center
    self.y -= 20
    self.text_box "<b>Date Paid:</b> #{@event_user.paid_at.to_date.to_s(:default)}", at: [180, self.y], width: 290, align: :center, inline_format: true, height: 16, size: 14, min_font_size: 12, valign: :center

    # Draw ticket stub
    self.image logo, at: [510, @options[:height] - @options[:padding] + 10]
    generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", 533, 20)

    self.fill_color "000000"
    self.y = 145
    self.text_box "#{UsersController.helpers.user_name(@event_user.user)}", at: [510, self.y], width: 130, align: :center, inline_format: true, height: 16, size: 14, min_font_size: 12, valign: :center
    self.y -= 20
    self.text_box "Paid on #{@event_user.paid_at.to_date.to_s(:default)}", at: [510, self.y], width: 130, align: :center, inline_format: true, height: 16, size: 14, min_font_size: 12, valign: :center
  end

  # def draw_ticket_2
  #   # Draws border
  #   # rectangle [@origin, @height + @origin], @width, @height

  #   # draw_vertical_dashed_line @stub_start_x

  #   # # Draws left side
  #   # draw_information_2

  #   # # Draws right side
  #   # draw_ticket_stub_2
  # end

  # def draw_information_2
  #   # Draws large event image along top
  #   move_cursor_to @height - 5
  #   table [
  #       [
  #         {
  #           image: event_image,
  #           fit: [@stub_start_x - 20, @height / 2 - 10],
  #           position: :center,
  #           padding: [0, 0, 0, 20]
  #         }
  #       ]
  #     ],
  #     cell_style: {
  #       width: @stub_start_x - 20,
  #       height: @height / 2 - 10,
  #       borders: []
  #     }

  #   # Draws information below image
  #   font_size 24
  #   text_box "#{@event.title}", style: :bold, at: [@origin + 10, @height / 2], width: @stub_start_x - 20, overflow: :shrink_to_fit, align: :center

  #   # Paid information, via, date, across bottom. Skim date to just show date not time
  #   font_size 12
  #   text_box "Admit One", at: [@origin + 10, 60], width: @stub_start_x - 20, align: :center
  #   text_box "#{@event_user.user.name || @event_user.user.email} paid via #{@event_user.payments[0].payment_method.name} on #{@event_user.paid_at.to_date}", at: [@origin + 10, 45], width: @stub_start_x - 20, align: :center
  # end

  # def draw_ticket_stub_2
  #   # Draws PayWithMe logo
  #   image pwm_image, at: [@stub_start_x + 10, 186], fit: [130, 100]

  #   # Draws some event_user information
  #   font_size 10
  #   text_box "#{@event_user.user.name || @event_user.user.email}", at: [@stub_start_x + 10, @height - 60], width: @width - @stub_start_x - 20, align: :center

  #   # Fix later
  #   text_box " paid #{@event_user.payments[0].payment_method.name} #{ActionController::Base.helpers.number_to_currency(@event_user.paid_total_cents / 100)}", at: [@stub_start_x + 10, @height - 70], width: @width - @stub_start_x - 20, align: :center

  #   # Draws qr code
  #   generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", @stub_start_x + 33, 10)
  # end

  # def draw_ticket
  #   # Draws border
  #   rectangle [@origin, @height], @width, @height

  #   draw_vertical_dashed_line @stub_start_x

  #   # Draws left side
  #   draw_information

  #   # Draws right side
  #   draw_ticket_stub
  # end

  # # Draws text based information on left side
  # def draw_information
  #   standard_size = font_size
  #   x_pos = 10
  #   y_pos = 180
  #   gap_size = 15

  #   font_size 10
  #   text_box "Your ticket to:", at: [x_pos, y_pos]

  #   y_pos -= gap_size

  #   # Draws event title
  #   font_size 24
  #   text_box "#{@event.title}", style: :bold, at: [x_pos, y_pos], width: 430, overflow: :truncate

  #   y_pos -= 2*gap_size

  #   font_size standard_size

  #   # Draws user name
  #   text_box "Name: #{@event_user.user.name || @event_user.user.email}", at: [x_pos, y_pos], width: 240
  #   y_pos -= gap_size

  #   # Draws payment method
  #   text_box "Payment Method: #{@event_user.payments[0].payment_method.name}", at: [x_pos, y_pos], width: 240
  #   y_pos -= gap_size

  #   # Draws paid at
  #   text_box "Date Paid: #{@event_user.paid_at}", at: [x_pos, y_pos], width: 240
  #   y_pos -= gap_size

  #   # Draws event description
  #   text_box "Event Details: #{@event.description}", at: [x_pos, y_pos], width: 240, height: 70, overflow: :truncate

  #   # Draws event image on ticket
  #   image event_image, at: [280, 170], fit: [160, 160]
  # end

  # # Draws ticket stub, right portion
  # def draw_ticket_stub
  #   image pwm_image, at: [@stub_start_x + 10, 186], fit: [130, 100]
  #   generate_and_display_qr("http://www.paywith.me/tickets/paid?event_user_id=#{@event_user.id}", @stub_start_x + 5, 15)
  # end

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
      default_image
    end
  end

  # Return vertical paywithme image path as string
  def logo_rotated
    "#{Rails.root}/app/assets/images/logo_black_rotated.png"
  end

  # Return paywithme image path as string
  def logo
    "#{Rails.root}/app/assets/images/ticket_logo.png"
  end

  # Return m image path as string
  def default_image
    "#{Rails.root}/app/assets/images/default_event_image_ticket.png"
  end

  def draw_vertical_dashed_line(x)
    # Value for size of line and space in between
    size = 5
    y = 0

    (@options[:height]/(size*2)).times do
      stroke_vertical_line y, y+size, at: x
      y += size*2
    end
  end
end