$(function()
{
    // User-show-page specific
    if ($('.invite-to-event-button').length > 0)
    {
        var mouse_is_inside = false;

        // Doing this using JQuery so that users with JS disabled can still use it
        $('.events-to-invite').hide();

        $('.invite-to-events').click(function()
        {
            $('.events-to-invite').toggle("fast");

            $(this).hasClass('disabled')
                ? $(this).removeClass('disabled')
                : $(this).addClass('disabled');

            return false;
        });

        // Hide the menu when the user's mouse moves out of the menu
        $('.invite-to-event-button').hover(function()
        {
            mouse_is_inside = true;
        }, function()
        {
            mouse_is_inside = false;
        });

        $("body").mouseup(function()
        {
            if(!mouse_is_inside)
            {
                $('.events-to-invite').hide("fast");
                $('.invite-to-events').removeClass('disabled');
            }
        });

        // Invite the user to the event
        $('.event-to-invite').click(function()
        {
            $(this).parent('form').submit();
            
            return false;
        });
    }
});