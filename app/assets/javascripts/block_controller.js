// block.js Controller
// Lets a single selected block be shown
// <select class="js-block-controller" data-group="{group}">
//    <option value="{id}"></option>
// </select>
// <div class="js-block" data-group="{group}" data-id="{id}">
// </div>
// .js-block-controller requirements:
// - respond to val()
// .js-block requirements:
// - none

!function($) {
  function blockControllerChange() {
    var group = $(this).data("group"),
      id = $(this).val(),
      $controlled_blocks = $(this).parent().find(".js-block[data-group="+group+"]"); // If necessary, make this selector more general
    $controlled_blocks.hide();
    $controlled_blocks.each(function() {
      if($(this).data("id").toString() === id) {
        $(this).show();
      }
    });
  }
  $(".js-block-controller").change(blockControllerChange);
  $(".js-block-controller").each(blockControllerChange);
}(window.jQuery);