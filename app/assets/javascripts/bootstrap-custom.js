$(function () {
  // Activates tooltips
  $("[rel='tooltip']").tooltip({
    container: 'body'
  });

  // Fixes dropdown menu links not being clickable on mobile
  $('body').on('touchstart.dropdown', '.dropdown-menu', function (e) {
    e.stopPropagation();
  });
});
