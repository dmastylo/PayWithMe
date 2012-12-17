$(function()
{
    // Event-show-page specific
    if ($('.message-list').length > 0)
    {
        // set first message to latest-message
        $(".message:first-child").addClass("latest-message");

        // Poll for new messages
        setTimeout(updateMessages, 5000);
    }
});


function updateMessages()
{
    var event_id = $(".message-list").attr("data-id");
    var after = $(".message").length > 0
              ? $(".message-list").find(".latest-message").attr("data-time")
              : "0";
    $.getScript("/messages.js?event_id=" + event_id + "&after=" + after);

    setTimeout(updateMessages, 5000);
}