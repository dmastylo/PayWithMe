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