$(function()
{
    $(".see-more").click(function()
    {
        var event_id = $(".message-list").attr("data-id");
        var last_message_time = $(".message").length > 0
                  ? $(".message:last").attr("data-time")
                  : "0";
        $.getScript("/messages.js?event_id=" + event_id + "&last_message_time=" + last_message_time);
    });
});