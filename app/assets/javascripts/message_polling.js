$(function()
{
    if ($('.message-list').length > 0)
    {
        setTimeout(updateMessages, 5000);
    }
});

function updateMessages()
{
    var event_id = $(".message-list").attr("data-id");
    var after = ($(".message").length > 0) ? $(".message:first-child").attr("data-time") : "0";
    $.getScript("/messages.js?event_id=" + event_id + "&after=" + after);
    setTimeout(updateMessages, 5000);
}