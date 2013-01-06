// Bool that will determine whether or not more content can be loaded
var moreContent = true;

// Bool that will prevent the scrolling from constantly be fired
var loading = false;

$(function()
{
    $('.message-list').scroll(function() {
        if (($(this)[0].scrollHeight - $(this).scrollTop() <= $(this).outerHeight() + 50) &&
            !loading && moreContent) {
            // Let the user know that the messages are being loaded
            $('.message-list').append('<span class="load-new-msgs">Loading new messages...</span>');

            var event_id = $(".message-list").attr("data-id");
            var last_message_time = $(".message").length > 0
                      ? $(".message:last").attr("data-time")
                      : "0";

            // currently loading new data so prevent this from being fired
            loading = true;

            $.getScript("/messages.js?event_id=" + event_id + "&last_message_time=" + last_message_time);
        }
    });

    // $(".see-more").click(function(e)
    // {
    //     e.preventDefault();
    //     var event_id = $(".message-list").attr("data-id");
    //     var last_message_time = $(".message").length > 0
    //               ? $(".message:last").attr("data-time")
    //               : "0";
    //     $.getScript("/messages.js?event_id=" + event_id + "&last_message_time=" + last_message_time);
    // });
});