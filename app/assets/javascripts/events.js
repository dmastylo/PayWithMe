function addMember(member)
{
	console.log(member);

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
}