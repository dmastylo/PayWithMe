!function($)
{
  var Wizard = function(element, options)
  {
    this.$element = $(element);
    this.options = options;
    this.currentStep = 1;

    this.listen();
    this.$element.find('.wizard-card').hide();
    this.$element.find("#wizard-card-"+this.currentStep).show();
  };

  Wizard.prototype = 
  {
    constructor: Wizard,

    listen: function()
    {
      var that = this;
      this.$element.find('.wizard-submit').click(function()
      {
        that.switchToCard(that.currentStep+1);
      });

      this.$element.find('.wizard-step').click(function()
      {
        that.switchToCard($(this).attr("id").replace("wizard-step-", ""));
      });
    },

    switchToCard: function(newStep)
    {
      this.$element.find("#wizard-step-"+this.currentStep).removeClass("active");
      this.$element.find("#wizard-step-"+this.currentStep+" i").removeClass("icon-white");
      this.$element.find("#wizard-card-"+this.currentStep).hide()
      this.currentStep = newStep;
      this.$element.find("#wizard-step-"+this.currentStep).addClass("active");
      this.$element.find("#wizard-step-"+this.currentStep+" i").addClass("icon-white");
      this.$element.find("#wizard-card-"+this.currentStep).show();

      this.$element.find("#wizard-card-"+this.currentStep+" .autosize").each(function()
      {
        $parent = $(this);
        
        $parent.parent().show();

        $fixed = $parent.find("span.add-on");
        $fluid = $parent.find("input");

        parentWidth = $parent.width();
        fixedWidth = $fixed.outerWidth(true);

        var calculatedOffset = $fluid.outerWidth(true) - $fluid.outerWidth();
        $fluid.css('width', (parentWidth - fixedWidth - calculatedOffset));

        if(!$parent.parent().hasClass("selected"))
          $parent.parent().hide();
      });
    }
  };

  $.fn.wizard = function(option) {
    return this.each(function () {
      var $this = $(this)
      , options = typeof option == 'object' && option;
      new Wizard(this, options);
    });
  }
}(window.jQuery);