!function($)
{
	var AutoSize = function(parent, options)
	{
		this.options = $.extend({}, $.fn.autoSize.defaults, options);
		this.$parent = $(parent);
		this.$fixed = this.$parent.find(this.options.fixed);
		this.$fluid = this.$parent.find(this.options.fluid);

		this.listen();
	}

	AutoSize.prototype = {

		constructor: AutoSize,

		resize: function()
		{
			if(this.options.minSize != -1)
			{
				if($(document).width() < this.options.minSize)
				{
					this.$fluid.css('width', 'inherit');
					return;
				}
			}

			if(this.$parent.is(":visible"))
			{
				parentWidth = this.$parent.width();
				fixedWidth = this.$fixed.outerWidth(true);
			}
			else
			{
				var $unhide;
				if(this.$parent.parent().is(":visible"))
				{
					$unhide = this.$parent;
				}
				else
				{
					$unhide = this.$parent.parent();
				}

				$unhide.show();
				parentWidth = this.$parent.width();
				fixedWidth = this.$fixed.outerWidth(true);
				$unhide.hide();
			}

			var calculatedOffset = this.$fluid.outerWidth(true) - this.$fluid.outerWidth();
			this.$fluid.css('width', (parentWidth - fixedWidth - calculatedOffset - this.options.offset));
		},

		listen: function()
		{
			var that = this;
			$(window).resize(function() { that.resize(); });
			$(document).ready(function() { that.resize(); });
			this.$parent.on('show', function() { that.resize(); })
		}
	}

	$.fn.autoSize = function(option)
	{
		return this.each(function()
		{
			var options = typeof option == 'object' && option;
			new AutoSize(this, options);
		});
	}

	$.fn.autoSize.defaults = {
		fixed: 'span.add-on,.btn',
		fluid: 'input',
		offset: 0,
		minSize: -1
	}
}(window.jQuery);