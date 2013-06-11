// catch_success.js
// Catches success from an AJAX request. A few options of what to do from there
// Method list:
// - replace: finds nearest parent .js-success, injects {html} from JSON, appends to #{destination} element
// Usage: render json: { method: :replace, html: {html}, destination: {destination} }
// <div class="js-catch-parent">(some form that succeeds)</div>
// Possible additions: (1) specify which parent .js-success

!function($) {
  $(".js-catch-success")
    .bind('ajax:success', function(evt, data, status, error) {
      var $form = $(this),
        $parent = $form.closest(".js-catch-parent");
      if(data.method === "replace") {
        console.log("TESTING");
        var $destination = $("#" + data.destination)
        $parent.html(data.html).appendTo($destination);
        $destination.show();
      }
    });
}(window.jQuery);