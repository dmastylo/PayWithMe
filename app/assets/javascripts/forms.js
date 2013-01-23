$(document).ready(function()
{
	$('.input-prepend,.input-append').autoSize();

  $("#btn-bulk-invite").click(function(e)
  {
    e.preventDefault();
    var $single = $("#single-invite");
    var $bulk = $("#bulk-invite");
    var $btn = $(this);

    if($single.is(':visible'))
    {
      $single.hide();
      $bulk.show();
      $btn.html('Single invitation mode');
    }
    else
    {
      $single.show();
      $bulk.hide();
      $btn.html('Bulk invitation mode');
    }
  });
});