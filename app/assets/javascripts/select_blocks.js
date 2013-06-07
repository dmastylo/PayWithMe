// select_blocks.js
// Simple library for using a <select> to show any elements
// Structure:
// <select class="js-block-controller" data-group="{group}">
//    <option value="{id}"></option>
// </select>
// <div class="js-block" data-group="{group}" data-id="{id}">
// </div>

!function($) {
  $(".js-block-controller").change(function() {
    var group = $(this).data("group"),
      id = $(this).val(),
      $controlled_blocks = $(this).parent().find(".js-block[data-group="+group+"]");
    $controlled_blocks.hide();
    $controlled_blocks.each(function() {
      if($(this).data("id").toString() === id) {
        $(this).show();
      }
    })
  });
  $(".js-selected-block").hide();
}(window.jQuery);