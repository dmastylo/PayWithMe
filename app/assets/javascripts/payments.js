$('.processor-logo').click(function()
{
	$this = $(this);
	name = $this.data('name');
	$input = $("#processor_"+name);
	
	if($this.hasClass('selected'))
	{
		$this.removeClass('selected');
		$input.val(false);
	}
	else
	{
		$this.addClass('selected');
		$input.val(true);
	}
});

$('.datepicker').datepicker().on('changeDate', function(e)
{
	$this = $(this);
	id = "#"+$this.attr("id") + "_";
	date = e.date;

	$(id+"1i").val(e.date.getUTCFullYear());
	$(id+"2i").val(e.date.getMonth() + 1);
	$(id+"3i").val(e.date.getDate());
});

$('#payment_type').change(function()
{
	$this = $(this);
	if($this.val() == "owe")
	{
		$("#payment-verb").html("to");
	}
	else
	{
		$("#payment-verb").html("from");
	}
});