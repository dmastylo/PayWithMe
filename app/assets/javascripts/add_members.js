!function($)
{
	var AddMembers = function(element, options)
	{
		this.$element = $(element);
		this.options = $.extend({}, $.fn.add_members.defaults, options);
		this.$add = $(this.options.add);
		this.$members_hidden = $(this.options.members_hidden);
		this.$members = $(this.options.members);
		this.$errors = $(this.options.errors);
		this.source = this.options.source;
		this.members = [];
		this.listen();
	}

	AddMembers.prototype = {

		constructor: AddMembers
	
		, select: function(member)
		{
			if(member.email == "" || member.email.indexOf("@") === -1 || member.email.indexOf(".") === -1)
			{
				this.$errors.html("Please enter a valid email address.").show();
				return;
			}
			else if(this.members.indexOf(member.email) !== -1)
			{
				var name = member.name || member.email;
				this.$errors.html("<strong>" + name + "</strong> has already been added.").show();
				this.$element.val("");
				return;
			}
			else
			{
				this.$errors.hide();
				member.email = member.email.toLowerCase();

				// TODO: Add check to see if already exists
				if(member.name)
				{
					$member = $("<div></div>").addClass("member")
						.append($("<div></div>")
							.addClass("profile_image").append($(member.profile_image))
						)
						.append($("<div></div>")
							.addClass("info")
							.append($("<div></div>")
								.addClass("name").html(member.name)
							)
							.append($("<div></div>")
								.addClass("email").html(member.email)
							)
						)
						.append($("<div></div>")
							.addClass("clearfix")
						)
					;
				}
				else
				{
					$member = $("<div></div>").addClass("member member_with_email")
						.append($("<div></div>")
							.addClass("email").html(member.email)
						)
					;
				}

				this.$members.prepend($member);
				this.$element.val("");

				this.members.push(member.email);
				this.$members_hidden.val(JSON.stringify(this.members));
			}
		}

		, handleSelect: function()
		{
			var $typeahead = $('.typeahead')
			if($typeahead.is(':visible'))
			{
				$typeahead.find('li.active').trigger('click');
			}
			else
			{
				var member = {'email': this.$element.val()};
				this.select(member);
			}
		}

		, handleSelects: function()
		{
			var that = this;

			this.$add.click(function(e)
      {
        e.preventDefault();
        that.handleSelect();
      });

      this.$element.keydown(function(e)
      {
        if(e.keyCode == 13)
        {
          e.preventDefault();
          that.handleSelect();
        }
      });
		}

		, typeahead: function()
		{
			var that = this;

			this.$element.typeahead({
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
			this.typeahead();
			this.handleSelects();
		}
	}

	$.fn.add_members = function (option) {
    return this.each(function () {
      var $this = $(this)
        , options = typeof option == 'object' && option;
      new AddMembers(this, options);
    })
  }

	$.fn.add_members.defaults = {
		add: '#add_member',
		members_hidden: '#event_members',
		members: '#invited_members',
		errors: '#add_member_error',
		source: '/users/search.json'
	}
}(window.jQuery);