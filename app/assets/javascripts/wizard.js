!function($)
{
  var Wizard = function(element, options)
  {
    this.$element = $(element);
    this.options = options;
    this.currentStep = 1;

    this.init();
    this.listen();
    this.$element.find('.wizard-card').hide();
    this.$element.find("#wizard-card-"+this.currentStep).show();
  };

  Wizard.prototype = 
  {
    constructor: Wizard,

    init: function()
    {
      // Later make this more general
      $("#event_division_type").change(function()
      {
        $(".event_division_type_option").hide();
        $(".event_division_type_option").removeClass("selected");
        $("#event_division_type_"+$(this).val()).show();
        $("#event_division_type_"+$(this).val()).addClass("selected");
      });
      $("#event_division_type_"+$("#event_division_type").val()).show();
      $("#event_division_type_"+$("#event_division_type").val()).addClass("selected");

      // Later make this more general
      $("#event_send_tickets").change(function()
      {
        if($(this).is(":checked"))
        {
          $("#event_send_tickets_option").show();
        }
        else
        {
          $("#event_send_tickets_option").hide();
        }
      })

      var found_error = false;
      var that = this;
      this.$element.find('.wizard-card').each(function()
      {
        var errors = $(this).find('.field_with_error');
        if(errors.length > 0)
        {
          var id = $(this).attr("id").replace("wizard-card-", "");
          var $step = $("#wizard-step-"+id);
          $step.find("i").removeClass("icon-chevron-right").addClass("icon-exclamation-sign");

          if(!found_error)
          {
            that.switchToCard(id);
            found_error = true;
          }
        }
      });
    },

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
      this.currentStep = parseInt(newStep);
      this.$element.find("#wizard-step-"+this.currentStep).addClass("active");
      this.$element.find("#wizard-step-"+this.currentStep+" i").addClass("icon-white");
      this.$element.find("#wizard-card-"+this.currentStep).show();

      this.$element.find("#wizard-card-"+this.currentStep+" .control-group").show();
      this.$element.find("#wizard-card-"+this.currentStep+" .autosize").trigger("show");
      this.$element.find("#wizard-card-"+this.currentStep+" .btn_group_option").each(function()
      {
        if($(this).hasClass("selected"))
          $(this).show();
      })
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