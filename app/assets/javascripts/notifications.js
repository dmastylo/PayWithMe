$('#dropdown-notifications').dropdown({
	onopen: function(dropdown)
	{
		$.ajax({
			url: '/users/read_notifications',
			type: 'GET'
		});

		$('.unread-notifications-count').hide();
	},
	onclose: function(dropdown)
	{
		$this.parent().find('li.unread').removeClass('unread');
	}
});

$('#dropdown-notifications').click(function()
{
	$this = $(this);
	if($this.parent().hasClass('open'))
	{
		$.ajax({
			url: '/users/read_notifications',
			type: 'GET'
		});

		// Likely some updating function here
	}
	else
	{
		$this.parent().find('li.unread').removeClass('unread');
		$('.unread-notifications-count').hide();
	}
});

$('#dropdown-menu').dropdown();