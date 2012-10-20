$('#search-users').typeahead({
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
				$("#search-users").val(value['query']);
				$("#search-form").submit();
			}
			else window.location = '/users/' + value['id'];
		}
	}
});