!function($)
{
	var FeeButtons = function(input, options)
	{
		// Load options
		this.$input = $(input); //Where does input come from?
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

	FeeButtons.prototype = {

		constructor: FeeButtons,

		onClick: function(e)
		{
			var $button = $(e.target);
			var value = $button.data("value");
			var name = $button.data("name");

			if(this.checkbox)
			{
				//This happens if the one clicked is already true

				this.val = [];
				var that = this; //Why is this needed?

				this.$buttons.each(function()
				{
					var $this = $(this); //Why is this needed?

					//XOR can be simplified to a comparison between boolean values.
					// ($this.hasClass('active')) !== ($button[0] == $this[0])
					if((!$this.hasClass('active') && $button[0] == $this[0]) || ($this.hasClass('active') && $button[0] !== $this[0]))
					{
						that.val.push($this.data("value")); //What does this line do?
					}
				});

				this.$input.val(JSON.stringify(this.val));
			}
			else if(!$button.hasClass('disabled'))
			{
				//This happens if the one clicked is false

				this.val = value;
				this.$input.val(value);
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

	$.fn.feeButtons = function(option)
	{
		return this.each(function()
		{
			var $this = $(this), options = typeof option == 'object' && option;
			new FeeButtons(this, options);
		});
	}
}(window.jQuery);