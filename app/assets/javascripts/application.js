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

$('#search-friends').typeahead({
	source: function(query, process)
	{
		$.ajax({
			url: '/users/search/' + query + '.json',
			success: function(data)
			{
				friends = [];

				for(i = 0; i < data.length; ++i)
				{
					friends[i] = data[i].name;
				}

				process(friends);
			}
		})
	},
	menu: '<ul class="typeahead dropdown-menu dropdown-menu-navigation"></ul>'
});

/*$("#search-friends").keypress(function()
{
	var name = $(this).val();

	if(name) $.ajax({
		url: '/users/search/' + name + '.json',
		success: function(data)
		{
			var $results = $("#search-results");
			$results.empty();
			
			for(i = 0; i < data.length; ++i)
			{
				friend = data[i];
				$friend = $('<div></div>').attr('data-id', friend.id).html(friend.name);
				$results.append($friend);
			}
		}
	})
})*/