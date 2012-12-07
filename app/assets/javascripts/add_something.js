!function($)
{
	var AddSomething = function(input, options)
	{
		// Load options
		this.options = $.extend({}, $.fn.addSomething.defaults, options);
		this.source = this.options.source;
		this.somethings = this.options.somethings || [];

		// Needed elements
		this.$input = $(input);
		this.$addButton = $(this.options.addButtonSelector);
		this.$somethingsInput = $(this.options.somethingsInputSelector);
		this.$somethings = $(this.options.somethingsSelector);
		this.$error = $(this.options.errorSelector);

		// Overiddable methods
		this.onValidate = this.options.onValidate || this.onValidate;
		this.onCreate = this.options.onCreate || this.onCreate;
		
		// Launch it with none selected
		this.listen();
	}

	AddSomething.prototype = {

		constructor: AddSomething

		, onValidate: function(something)
		{
			return;
		}

		, onCreate: function(something)
		{
			var $something;
			if(something.name)
			{
				$something = $("<div></div>").addClass("member")
					.append($("<div></div>")
						.addClass("profile_image").append($(something.profile_image))
					)
					.append($("<div></div>")
						.addClass("info")
						.append($("<div></div>")
							.addClass("name").html(something.name)
						)
						.append($("<div></div>")
							.addClass("email").html(something.email)
						)
					)
					.append($("<div></div>")
						.addClass("clearfix")
					)
				;
			}
			else
			{
				$something = $("<div></div>").addClass("member member_with_email")
					.append($("<div></div>")
						.addClass("email").html(something.email)
					)
				;
			}

			return $something;
		}
	
		, select: function(something)
		{
			var error_message = this.onValidate(something);
			if(error_message)
			{
				this.$error.html(error_message).show();
				return;
			}
			else if(!this.options.allowNameless && !something[this.options.idAttribute])
			{
				return;
			}
			else if(this.somethings.indexOf(something[this.options.idAttribute]) !== -1)
			{
				var name = something[this.options.displayAttribute] || something[this.options.idAttribute];
				this.$error.html("<strong>" + name + "</strong> has already been added.").show();
				this.$input.val("");
				return;
			}
			else
			{
				this.$error.hide();
				$something = this.onCreate(something);

				this.$somethings.prepend($something);
				this.$input.val("");

				this.somethings.push(something[this.options.idAttribute]);
				this.$somethingsInput.val(JSON.stringify(this.somethings));
			}
		}

		, handleSelect: function()
		{
			var $typeahead = $('.typeahead')
			if($typeahead.is(':visible'))
			{
				$typeahead.find('li.active').trigger('click');
			}
			else if(this.options.allowNameless)
			{
				var something = {};
				somthing[this.option.idAttribute] = this.$input.val();
				this.select(something);
			}
		}

		, handleSelects: function()
		{
			var that = this;

			this.$addButton.click(function(e)
			{
				e.preventDefault();
				that.handleSelect();
			});

			this.$input.keydown(function(e)
			{
				if(e.keyCode == 13)
				{
					e.preventDefault();
					that.handleSelect();
				}
			});
		}

		, initializeTypeahead: function()
		{
			var that = this;

			this.$input.typeahead({
				key: that.options.idAttribute,
				property: that.options.displayAttribute,
				source: function(query, process)
				{
					$.ajax({
						url: that.source,
						type: 'GET',
						data: { name: query },
						dataType: 'json',
						success: function(data)
						{
							process(data);
						}
					})
				},
				menu: '<ul class="typeahead dropdown-menu dropdown-menu-navigation"></ul>',
				onselect: function(value)
				{
					var value = $.parseJSON(value);
					that.select(value);
				}
			});
		}

		, listen: function()
		{
			this.initializeTypeahead();
			this.handleSelects();
		}
	}

	$.fn.addSomething = function (option) {
		return this.each(function () {
			var $this = $(this)
			, options = typeof option == 'object' && option;
			new AddSomething(this, options);
		});
	}

	$.fn.addSomething.defaults = {
		addButtonSelector: '#add_member',
		somethingsInputSelector: '#event_members',
		somethingsSelector: '#invited_members',
		errorSelector: '#add_member_error',
		source: '/users/search.json',
		idAttribute: 'email',
		displayAttribute: 'name',
		allowNameless: true
	}
}(window.jQuery);