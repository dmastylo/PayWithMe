$('#dropdown-notifications').dropdown({
	onopen: function(dropdown)
	{
		$.ajax({
			url: '/users/read_notifications',
			type: 'GET'
		});
	},
	onclose: function(dropdown)
	{
		$this.parent().find('li.unread').removeClass('unread');
		$('.unread-notifications-count').hide();
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