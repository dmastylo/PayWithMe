!function($)
{
	var ButtonGroup = function(input, options)
	{
		// Load options
		this.$input = $(input);
		this.name = this.$input.attr("id");
		this.$buttons = $("#" + this.name + "_btn_group button");
		this.$children = $("." + this.name + "_option");
		this.checkbox = $("#" + this.name + "_btn_group").data('toggle') == 'buttons-checkbox'
		this.val = this.$input.val();
		if(this.checkbox && this.val)
		{
			this.val = JSON.parse(this.val);
		}

		this.onCreate();
	};

	ButtonGroup.prototype = {

		constructor: ButtonGroup,

		onClick: function(e)
		{
			var $button = $(e.target);
			var value = $button.data("value");
			var name = $button.data("name");

			if(this.checkbox)
			{
				this.val = [];
				var that = this;
				this.$buttons.each(function()
				{
					var $this = $(this);
					if((!$this.hasClass('active') && $button[0] == $this[0]) || ($this.hasClass('active') && $button[0] !== $this[0])) // XOR
					{
						that.val.push($this.data("value"));
					}
				});

				this.$input.val(JSON.stringify(this.val));
			}
			else if(!$button.hasClass('disabled'))
			{
				this.val = value;
				this.$input.val(value);
				this.$children.hide();		//Comment this line to allow more than 1 to appear
				this.showChild(name);
			}
		},

		onCreate: function()
		{
			var that = this;
			this.$buttons.on('click', $.proxy(that.onClick, that));

			if(this.val)
			{
				if(this.checkbox)
				{
					this.$buttons.each(function()
					{
						var $this = $(this);
						var val = $this.data("value");
						if($.inArray(val, that.val) !== -1)
						{
							$this.addClass('active');
						}
						else
						{
							$this.removeClass('active');
						}
					});
				}
				else
				{
					this.$buttons.each(function()
					{
						if($(this).data("value") == that.val) $(this).trigger('click');
					});
				}
			}
		},

		showChild: function(name)
		{
			$("." + this.name + "_option#" + this.name + "_" + name).fadeIn();
		}

	}

	$.fn.buttonGroup = function(option)
	{
		return this.each(function()
		{
			var $this = $(this), options = typeof option == 'object' && option;
			new ButtonGroup(this, options);
		});
	}
}(window.jQuery);