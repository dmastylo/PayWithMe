// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$('.dropdown-toggle').dropdown({
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

$('.dropdown-toggle').click(function()
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

$('#search-friends').typeahead({
	source: function(query, process)
	{
		$.ajax({
			url: '/users/search.json',
			type: 'POST',
			data: { name: query },
			dataType: 'json',
			success: function(data)
			{
				data[data.length] = {id: -1, name: "Search All Users", query: query}
				process(data);
			}
		})
	},
	menu: '<ul class="typeahead dropdown-menu dropdown-menu-navigation"></ul>',
	onselect: function(value)
	{
		value = $.parseJSON(value);
		if(value['id'])
		{
			if(value['id'] == '-1')
			{
				$("#search-form").submit();
			}
			else window.location = '/users/' + value['id'];
		}
	}
});

