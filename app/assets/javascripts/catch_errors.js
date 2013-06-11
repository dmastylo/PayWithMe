// catch_errors.js
// Catches errors from an AJAX request, displays them reasonably
// Structure:
// form_for ... remote: true, class: "js-catch-errors"
// <input class="js-catch-error" /> (only needed if form contains more than one input)

!function($) {
  var TOOLTIP_SHOW = 7000, // TODO: Move this to configuration somewhere
    timer;
  $(".js-catch-errors")
    .bind('ajax:error', function(evt, data, status, error) {
      clearTimeout(timer);
      var $form = $(this),
        errors = data.responseJSON;
      $.each(errors, function(key, msg) {
        var keys = key.split("_").map(function(s) { return s.toLowerCase() });
        keys[0] = keys[0].charAt(0).toUpperCase() + keys[0].substr(1, keys[0].length); // This is totally unreadable but very condensed
        var error_msg = keys.join(" ") + " " + msg;
        var $input = $form.find(".js-catch-error");
        if($input.length == 0) $input = $form.find("input[type=text]");
        $input.tooltip('destroy').tooltip({
          placement: 'top',
          container: 'body',
          trigger: 'manual',
          title: error_msg,
        }).tooltip('show');
        timer = setTimeout(function() { $input.tooltip('destroy') }, TOOLTIP_SHOW);
      });
    });
}(window.jQuery);