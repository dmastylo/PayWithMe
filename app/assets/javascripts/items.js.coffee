jQuery ->

  # Backend event form handlers
  # =========================================================

  # A simple filler to handle the btn-group
  # Not using button_group.js because not structured
  # entirely the same and it isn't very dynamic
  handleQuantityChange = (e) ->
    $el = $(this).parent().parent().parent().find(".item-quantity-yes")
    if $(this).data("name") is "allow"
      $el.show()
    else
      $el.hide()
    $(this).parent().parent().find("input").val $(this).data("value")

  # Bind the event
  $(".item-quantity button").click handleQuantityChange

  # Handle initial state
  $(".item-quantity-hidden").each ->
    if $(this).val() == "t"
      $($(this).parent().find("button")[0]).addClass("active")
      $(this).parent().parent().find(".item-quantity-yes").show()
    else
      $($(this).parent().find("button")[1]).addClass("active")

  # Handle changes when adding a field
  $(document).on "nested:fieldAdded", (e) ->
    $field = e.field
    $items = $("#items")
    $field.find(".number").html($items.find(".fields:visible").length)
    $field.find(".item-quantity button").click handleQuantityChange

  # Handle changes when removing a field
  $(document).on "nested:fieldRemoved", (e) ->
    $field = e.field
    $items = $("#items")
    id = 1
    $items.find(".fields:visible").each ->
      $this = $(this)
      $this.find(".number").html(id++)

  # Frontend item selection handlers
  # =========================================================

  # Updates the total price on the pay button
  updateItemsTotal = (e) ->
    $items = $(".item-total")
    if $items.length == 0
      return
    sum = 0
    $items.each ->
      html = $(this).html()
      value = html.replace("$", "")
      sum += parseFloat(value)
    $(".items-total").html("$" + sum.toFixed(2))
    if sum == 0
      $(".pay-buttons").hide()
    else
      $(".pay-buttons").show()

  # Updates the individual amount for a single item
  updateItemSingle = (item) ->
    $total = $(item).parent().find(".item-total")
    price = $(item).attr("data-amount")
    quantity = $(item).val()
    $total.html("$" + (price * quantity).toFixed(2))

  # Handle changing an item quantity
  $(".item-quantity").change (e) ->
    updateItemSingle(this)
    updateItemsTotal()

  # Initially set the total amount and single amounts
  $(".item-quantity").each ->
    updateItemSingle(this)
  updateItemsTotal()

  # Handle submitting the form
  $("#items .btn-pay").click (e) ->
    e.preventDefault()
    $("#payment_payment_method_id").val($(this).data("method"))
    $(this).parent().parent().submit()
    false