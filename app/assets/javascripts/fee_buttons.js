$(document).ready(function()
{

	var $pwmFee = $("#paywithme-fee");
	var $paypalFee = $("#paypal-fee");
	var $dwollaFee = $("#dwolla-fee");

	$("#allow-dwolla-payment").click(function(e)
	{
		if($dwollaFee.is(':visible'))
		{
			$dwollaFee.hide();

			if(!$paypalFee.is(':visible'))
			{
				$pwmFee.hide();
			}
		}
		else
		{
			$dwollaFee.show();
			$pwmFee.show();
		}
	});

	$("#allow-paypal-payment").click(function(e)
	{
		if($paypalFee.is(':visible'))
		{
			$paypalFee.hide();

			if(!$dwollaFee.is(':visible'))
			{
				$pwmFee.hide();
			}
		}
		else
		{
			$paypalFee.show();
			$pwmFee.show();
		}
	});
});