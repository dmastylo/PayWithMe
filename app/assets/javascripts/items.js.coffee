jQuery ->
	id = 1
	$("#add-item").click (e) ->
		e.preventDefault()
		template = $("#item-template").html()
		template = template.replace /_0/g, "_#{id}"
		template = template.replace /\[0\]/g, "[#{id}]"
		template = template.replace "Item #1", "Item ##{id+1}"
		$("#items").append template
		$("#item_#{id} .item-quantity button").click handleQuantityChange
		++id
	handleQuantityChange = (e) ->
		el = $(this).parent().parent().parent().find(".item-quantity-yes")
		console.log el
		if $(this).data("name") is "allow"
			el.show()
		else
			el.hide()
		$(this).parent().parent().find("input").val $(this).data("value")
	$(".item-quantity button").click handleQuantityChange

	updateItemsTotal = (e) ->
		sum = 0
		$(".item-total").each ->
			html = $(this).html()
			value = html.replace("$", "")
			sum += parseFloat(value)
		$(".items-total").html("$" + sum.toFixed(2))

	$(".item-quantity").change (e) ->
		$total = $(this).parent().find(".item-total")
		price = $(this).attr("data-amount")
		quantity = $(this).val()
		$total.html("$" + (price * quantity).toFixed(2))
		updateItemsTotal()

	updateItemsTotal()