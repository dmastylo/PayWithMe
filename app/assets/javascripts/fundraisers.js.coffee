jQuery ->

  # Frontend fundraiser handlers
  # =========================================================

  # Handle submitting the form
  $("#fundraiser .btn-pay").click (e) ->
    e.preventDefault()
    $("#payment_payment_method_id").val($(this).data("method"))
    $(this).parent().parent().submit()
    false

  # Handle updating the amount
  $("#fundraiser #payment_amount").keydown (e) ->
    if e.keyCode == 13
      e.preventDefault
      method = $("#fundraiser .btn-pay").data "method"
      $("#payment_payment_method_id").val method
      $("#fundraiser form").submit
    else
      total = parseFloat $(this).val()
      $total = $(this).parent().parent().find(".pay-total")
      if isNaN total
        $total.html ""
      else
        $total.html "$" + total.toFixed(2)