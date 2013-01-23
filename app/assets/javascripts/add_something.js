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
    this.$addBulkButton = $(this.options.addBulkButtonSelector);
    this.$somethingsInput = $(this.options.somethingsInputSelector);
    this.$somethingsMultipleTextarea = $(this.options.somethingsMultipleTextareaSelector);
    this.$somethings = $(this.options.somethingsSelector);
    this.$somethingsTemplate = $(this.options.somethingsTemplateSelector);
    this.$error = $(this.options.errorSelector);

    // Overiddable methods
    this.onValidate = this.options.onValidate || this.onValidate;
    
    // Launch it
    this.listen();
  };

  AddSomething.prototype = {

    constructor: AddSomething

    , onValidate: function(something)
    {
      var emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

      if (emailRegex.test(something[this.options.idAttribute]))
      {
        return;
      }
      else
      {
        return "Invalid email address!";
      }
    }

    , onCreate: function(something)
    {
      return Mustache.to_html(this.$somethingsTemplate.html(), something);
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

        this.handleDeletes();
      }
    }

    , delete: function($something)
    {
      var email = $something.find('.email').html();
      this.somethings = $.grep(this.somethings, function(sEmail)
      {
        return sEmail != email;
      });

      $something.remove();
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
        something[this.options.idAttribute] = this.$input.val();
        something["stub"] = true;
        this.select(something);
      }
    }

    , handleBulkSelect: function()
    {
      var emails = this.$somethingsMultipleTextarea.val();
      var that = this;
      emails = emails.replace(/,\s*/gm, ",").split(",");
      $.each(emails, function(index, email)
      {
        var something = {};
        something[that.options.idAttribute] = email;
        that.select(something);
      });
      this.$somethingsMultipleTextarea.val('');
    }

    , handleSelects: function()
    {
      var that = this;

      this.$addButton.click(function(e)
      {
        e.preventDefault();
        that.handleSelect();
      });

      if(this.options.bulkEnabled) this.$addBulkButton.click(function(e)
      {
        e.preventDefault();
        that.handleBulkSelect();
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

    , handleDeletes: function()
    {
      var that = this;
      var $deletes = this.$somethings.find(".delete");

      $deletes.unbind("click");
      $deletes.click(function()
      {
        that.delete($(this).parent());
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
      this.handleDeletes();
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
    addBulkButtonSelector: '#add_members',
    somethingsMultipleTextareaSelector: '#member_names',
    somethingsInputSelector: '#event_members',
    somethingsSelector: '#invited_members',
    somethingsTemplateSelector: '#invited_user_template',
    errorSelector: '#add_member_error',
    source: '/users/search.json',
    idAttribute: 'email',
    displayAttribute: 'name',
    allowNameless: true,
    bulkEnabled: false
  }
}(window.jQuery);