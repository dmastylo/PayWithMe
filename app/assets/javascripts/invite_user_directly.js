$(function()
{
    // User-show-page specific
    if ($('.invite-to-event-button').length > 0)
    {
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

        $('.event-to-invite').click(function()
        {
            $(this).parent('form').submit();
            
            return false;
        });
    }
});