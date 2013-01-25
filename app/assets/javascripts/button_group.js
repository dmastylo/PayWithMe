!function($)
{
	var ButtonGroup = function(input, options)
	{
		// Load options
		this.$input = $(input);
		this.name = this.$input.attr("id");
		this.$buttons = $("#" + this.name + "_btn_group button");
		this.$children = $("." + this.name + "_option");
		this.val = this.$input.val();

		this.onCreate();
	};

	ButtonGroup.prototype = {

		constructor: ButtonGroup,

		onClick: function()
		{
			var $this = $(this);
			var value = $this.data("value");
			var name = $this.data("name");

			if(!$this.hasClass('disabled'))
			{
				that.val = value;
				that.$input.val(value);
				that.$children.hide();
				that.showChild(name);
			}
		},

		onCreate: function()
		{
			var that = this;
			this.$buttons.click(function()
			{
				var $this = $(this);
				var value = $this.data("value");
				var name = $this.data("name");

				if(!$this.hasClass('disabled'))
				{
					that.val = value;
					that.$input.val(value);
					that.$children.hide();
					that.showChild(name);
				}
			});

				console.log(this.val);
			if(this.val)
			{
				this.$buttons.each(function()
				{
					if($(this).data("value") == that.val) $(this).trigger('click');
				})
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