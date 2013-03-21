class EventPdf < Prawn::Document
  
  # Initializes the document
  def initialize(event, view)
    super()
    @event = event
    @view = view

    font_families.update(
      "Lato" => {
        bold: "#{Rails.root}/app/assets/fonts/Lato-Bold.ttf",
        normal: "#{Rails.root}/app/assets/fonts/Lato-Regular.ttf"
      }
    )

    font("Lato")

    display_header
    move_down 20
    display_table

    number_pages "<page> of <total>", 
    {
      start_count_at: 1,
      at: [bounds.right - 50, 0],
      align: :right,
      size: 8
    }
  end

  # Header information
  def display_header

    event_data = [
      ["<font size='24'><b>#{@event.title}</b></font>"], 
      ["Organized By: #{User.find_by_id(@event.organizer_id).name}"],
      [privacy_setting],
      ["Amount Per Person: #{price_cents(@event.split_amount_cents)}"],
      ["Total Collected: #{price_cents(@event.money_collected_cents)}"],
      ["Money Due: #{@event.due_at_time}, #{@event.due_at_date}"]
    ]

    tmpTable = make_table(event_data, cell_style: { borders: [], overflow: :shrink_to_fit, inline_format: true })

    full_data = [[ {image: event_image, fit: [150, 150], vposition: :center, position: :center, padding_right: 15 }, tmpTable ]]

    table full_data, cell_style: { borders: [] }
  end

  # Table information
  def display_table
    table line_item_rows do     
      row(0).font_style = :bold
      columns(0..4).align = :center
      column(0).width = 160
      column(1).width = 120
      column(2).width = 115
      column(3).width = 90
      column(4).width = 55
      self.row_colors = ["DDDDDD", "FFFFFF"]
      self.header = true
      overflow = :shrink_to_fit
    end
  end

  # Row information
  def line_item_rows
    [["Name", "Payment Amount", "Paid Via", "Paid On", "Arrived"]] + 
    @event.paying_members.map do |member|

      # Get proper name to display
      name = member.name || member.email

      # Get rest of information
      event_user = EventUser.find_by_user_id_and_event_id(member.id, @event.id)

      if event_user.paid?
        amount = price(event_user.amount)
        payment_method_name = event_user.payments[0].payment_method.name
        pay_date = event_user.paid_at.to_date
      elsif event_user.paid_total_cents > 0
        # If the user partially paid
        amount = price(event_user.paid_total)
        payment_method_name = event_user.payments[0].payment_method.name
        pay_date = ""
      else
        amount = "Not Paid"
        payment_method_name = ""
        pay_date = ""
      end 

      # Put information into table
      [name, amount, payment_method_name, pay_date, ""]
    end
  end

  # Returns text of private or public event
  def privacy_setting
    (@event.private? ? "Private " : "Public ") + "Event"
  end

  # Turns price in cents to money value in dollars
  def price_cents(val = 0)
    if !val
      val = 0
    end 
    price(val/100.0)
  end

  # Turns price to dollars
  def price(val)
    @view.number_to_currency(val)
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
end