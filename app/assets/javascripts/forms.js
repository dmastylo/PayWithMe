function resizeInputsWithAddons()
{
	$('.input-prepend,.input-append').each(function()
	{
		$parent = $(this);
		$addon = $parent.find('span.add-on,.btn');
		if($parent.is(":visible"))
		{
			parentWidth = $parent.width();
			addonWidth = $addon.outerWidth();
		}
		else
		{
			// Assumes that the parent node is what actually has display: none;
			// Or whatever CSS is used to hide things
			$parent.parent().show();
			parentWidth = $parent.width();
			addonWidth = $addon.outerWidth();
			$parent.parent().hide();
		}

		$input = $parent.find('input');
		$input.css('width', (parentWidth - addonWidth));
	});
}

$(document).ready(resizeInputsWithAddons);
$(window).resize(resizeInputsWithAddons);