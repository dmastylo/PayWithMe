$(document).ready(function()
{
	$("#notifications-dropdown-toggle").click(function()
	{
		if(!$(this).parent().hasClass('open'))
		{
			$(".unread-notifications-count").hide();
			$.ajax({
				url: Routes.read_notifications_path({format: 'js'}),
				type: 'POST'
			});
		}
	});
});