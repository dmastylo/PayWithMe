$(document).ready(function()
{
  $("#btn-mobile-sidebar").click(function()
  {
    var $sidebar = $("#mobile-sidebar");
    $sidebar.css('right', -300);
    $sidebar.show();
    $sidebar.animate({right: 0}, 400, 'linear');

    $("#mobile-sidebar-helper").show();
    $("#mobile-sidebar-helper").css('width', $(window).width() - $sidebar.width());
  });

  $("#mobile-sidebar-helper").click(function()
  {
    var $sidebar = $("#mobile-sidebar");
    $sidebar.animate({right: -300}, 400, 'linear', function() { $(this).hide(); });
    $(".navbar,.container,.footer").unbind('click');
    $("#mobile-sidebar-helper").hide();
  });
});