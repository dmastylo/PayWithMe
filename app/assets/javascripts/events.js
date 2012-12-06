var members = [];

function addMember(member)
{
	if(member.email == "" || member.email.indexOf("@") === -1 || member.email.indexOf(".") === -1)
	{
		$("#add_member_error").html("Please enter a valid email address.").show();
		return;
	}
	else if(members.indexOf(member.email) !== -1)
	{
		var name = member.name || member.email;
		$("#add_member_error").html("<strong>" + name + "</strong> has already been added.").show();
		$("#member_name").val("");
		return;
	}
	else
	{
		$("#add_member_error").hide();
		member.email = member.email.toLowerCase();

		// TODO: Add check to see if already exists
		if(member.name)
		{
			$member = $("<div></div>").addClass("member")
				.append($("<div></div>")
					.addClass("profile_image").append($(member.profile_image))
				)
				.append($("<div></div>")
					.addClass("info")
					.append($("<div></div>")
						.addClass("name").html(member.name)
					)
					.append($("<div></div>")
						.addClass("email").html(member.email)
					)
				)
				.append($("<div></div>")
					.addClass("clearfix")
				)
			;
		}
		else
		{
			$member = $("<div></div>").addClass("member member_with_email")
				.append($("<div></div>")
					.addClass("email").html(member.email)
				)
			;
		}

		$("#invited_members").prepend($member);
		$("#member_name").val("");

		members.push(member.email);
		$("#event_members").val(JSON.stringify(members));
	}
}

function handleAddMember()
{
  var $typeahead = $('.typeahead');
  if($typeahead.is(':visible'))
  {
    $typeahead.find('li.active').trigger('click');
  }
  else
  {
    var member = {'email': $("#member_name").val()};
    addMember(member);
  }
}