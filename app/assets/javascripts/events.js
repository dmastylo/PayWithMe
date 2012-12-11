function fadeInNewMessages()
{
    // fade in new messages
    $('.new-message').each(function()
    {
        $(this).fadeIn();
    });
}

function temporarySpamBlock()
{
    // Disable the ability to post a new message for a second
    if ($('.post-message').attr("disabled"))
    {
        $('.post-message').removeAttr("disabled");
    }
    else
    {
        $('.post-message').attr("disabled", "disabled");
        setTimeout(temporarySpamBlock, 1000);
    }
}