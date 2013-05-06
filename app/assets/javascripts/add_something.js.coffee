jQuery ->

  # Typical constructor
  AddSomething = (input, options) ->
    # Load options
    this.options = $.extend({}, $.fn.addSomething.defaults, options)
    this.source = this.options.source
    this.somethings = this.options.somethings || []

    # Needed elements
    this.$input = $(input)
    this.$addButton = $(this.options.addButtonSelector)
    this.$addBulkButton = $(this.options.addBulkButtonSelector)
    this.$somethingsInput = $(this.options.somethingsInputSelector)
    this.$somethingsMultipleTextarea = $(this.options.somethingsMultipleTextareaSelector)
    this.$somethings = $(this.options.somethingsSelector)
    this.$somethingsTemplate = $(this.options.somethingsTemplateSelector)
    this.$error = $(this.options.errorSelector)

    # Overiddable methods
    this.onValidate = this.options.onValidate || this.onValidate

    # Launch it
    this.listen()
    

  AddSomething.prototype = {

    constructor: AddSomething,

    # Returns false if no error is found, otherwise the error message
    # Can be overridden by your own method
    onValidate: (something) ->
      emailRegex = /^(([^<>()[\]\\.,:\s@\"]+(\.[^<>()[\]\\.,:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      if emailRegex.test something[this.options.idAttribute]
        error = false
      else
        error = "Invalid email address!"
      error

    # Handles creating a something
    onCreate: (something) ->
      Mustache.to_html this.$somethingsTemplate.html(), something

    # Called when something is selected in the typeahead
    select: (something) ->
      error_message = this.onValidate something
      name = something[this.options.displayAttribute] || something[this.options.idAttribute]

      if error_message
        this.$error.html(error_message).show()
      else if this.somethings.indexOf(something[this.options.idAttribute]) != -1
        this.$error.html("<strong>" + name + "</strong> has already been added.").show()
        this.$input.val ""
      else if this.options.allowNameless || something[this.options.idAttribute]
        this.$error.hide()
        $something = this.onCreate something

        this.$somethings.prepend $something
        this.$input.val ""

        this.somethings.push something[this.options.idAttribute]
        this.$somethingsInput.val JSON.stringify this.somethings

        this.handleDeletes()

    # Deletes an item and removes it from the stringify'd value
    deleteIt: (something) ->
      $something = something
      id = $something.data 'id'

      this.somethings = $.grep(this.somethings, (removeId) -> removeId != id)
      this.$somethingsInput.val JSON.stringify this.somethings

      $something.remove()

    # Callback function used by the typeahead, sends data into select
    handleSelect: ->
      $typeahead = $('.typeahead')
      something = {}

      if $typeahead.is ':visible'
        $typeahead.find('li.active').trigger('click')
      else if this.options.allowNameless
        something[this.options.idAttribute] = this.$input.val()
        something.stub = true
        this.select something

    # Callback function used by bulk select form, sends data into select
    handleBulkSelect: ->
      emails = this.$somethingsMultipleTextarea.val().replace(/\s+/gm, ",").replace(/\s*,+\s*/gm, ",").split(",")
      that = this

      $.each emails, (index, email) ->
        something = {}
        something[that.options.idAttribute] = email
        something.stub = true
        that.select something
      this.$somethingsMultipleTextarea.val ""

    # Binds events for selecting
    handleSelects: ->
      that = this

      this.$addButton.click (e) ->
        e.preventDefault()
        that.handleSelect()

      if this.options.bulkEnabled
        this.$addBulkButton.click (e) ->
          e.preventDefault()
          that.handleBulkSelect()

      this.$input.keydown (e) ->
        if e.keyCode == 13
          e.preventDefault()
          that.handleSelect()

    # Bind events for deleting
    handleDeletes: ->
      that = this
      $deletes = this.$somethings.find(".delete")

      $deletes.unbind "click"
      $deletes.click ->
        that.deleteIt $(this).parent()

    # Sets up the typeahead
    initializeTypeahead: ->
      that = this

      this.$input.typeahead
        key: that.options.idAttribute,
        property: that.options.displayAttribute
        source: (query, process) ->
          $.ajax
            url: that.source
            type: "GET",
            data:
              name: query
            dataType: 'json'
            success: (data) ->
              process(data)
              false
        menu: '<ul class="typeahead dropdown-menu dropdown-menu-navigation"></ul>'
        onselect: (value) ->
          value = $.parseJSON(value)
          that.select(value)

    # Initializes the typeahead, calls all methods that bind events
    listen: ->
      this.initializeTypeahead()
      this.handleSelects()
      this.handleDeletes()
  }

  $.fn.addSomething = (option) ->
    this.each ->
      options = typeof option == 'object' && option
      new AddSomething(this, options)

  $.fn.addSomething.defaults =
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

  true