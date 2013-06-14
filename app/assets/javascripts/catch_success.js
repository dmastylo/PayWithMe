// catch_success.js
// Catches success from an AJAX request. A few options of what to do from there
// Method list:
// - replace: finds nearest parent .js-success, injects {html} from JSON, appends to #{destination} element
// (to be continued, one possibility is just displaying a tooltip like catch_errors.js)
// Usage: render json: { method: :replace, html: {html}, destination: {destination} }
// <div class="js-catch-parent">(some form that succeeds)</div>
// Possible additions: (1) specify which parent .js-success

!function($) {
  $(".js-catch-success")
    .bind('ajax:success', function(evt, data, status, error) {
      var $form = $(this),
        $parent = $form.closest(".js-catch-parent");
      if(data.method === "replace") {
        var $destination = $("#" + data.destination),
          $source = $parent.parent().parent(); // TODO: Make this more general, I want to have a .js-hide-empty that hides an element without any child .js-blocks but the listeners for changing the innerHTML (search for DOM change listeners) aren't supported in all browsers
        $parent.appendTo($destination).replaceWith(data.html);
        $destination.parent().show();
        console.log($source);
        if($source.find(".js-block").length == 0) {
          $source.hide();
        }
      }
    });
}(window.jQuery);