$(function () {
  // Activates tooltips
  $("[rel='tooltip']").tooltip({
    container: 'body'
  });

  // Fixes dropdown menu links not being clickable on mobile
  $('.dropdown-menu').on('touchstart.dropdown.data-api', function(e)
  {
    e.stopPropagation();
  });
});