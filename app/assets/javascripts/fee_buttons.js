$(document).ready(function()
{
	var $pwmFeeDiv = $("#paywithme-fee");
	var $paypalFeeDiv = $("#paypal-fee");
	var $dwollaFeeDiv = $("#dwolla-fee");
	var $wepayFeeDiv = $("#wepay-fee");

	var $pwmField = $("#paywithme-fee-field");
	var $paypalField = $("#paypal-fee-field");
	var $dwollaField = $("#dwolla-fee-field");
	var $wepayField = $("#wepay-fee-field");

	var $totalAmount = $("#event_total_amount");
	var $splitAmount = $("#event_split_amount");
	var $fundAmount = $("#event_fund_amount");

	var $totalButton = $("#payment-option-total");
	var $splitButton = $("#payment-option-total");
	var $fundButton = $("#payment-option-total");

	var $numFieldsVisible = 0;

	//Function to convert number value into a money value
	Number.prototype.toMoney = function(decimals)
	{ 
	   	var n = this,
	   	c = 2, 
	   	d = '.',
	   	t = ',',

	   	i = parseInt(n = Math.abs(n).toFixed(c)) + '', 

		j = ((j = i.length) > 3) ? j % 3 : 0; 
	   	return (j ? i.substr(0, j) + t : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (d + Math.abs(n - i).toFixed(c).slice(2)); 
	}

	//Currently should do nothing if Fundraiser is selected (needs donation amount)

	//For total, should split total between all members added to the event
	//For amount, should just calculate based on that value

	function calculateFees(){

		var $value = 0;
		var $paypalFee = 0;
		var $dwollaFee = 0;
		var $wepayFee = 0;
		var $pwmFee = 0;
		var $members = 0;

		//Determine value owed per person
		if($totalAmount.is(':visible'))
		{
			$value = $totalAmount.val();

			//Need to determine amount of people in event *******************************************************************
			$members = 1;

			//Should loop through things with the class 'member' keeping a count of all of them

			$value /= $members;
		}
		else if($splitAmount.is(':visible'))
		{
			$value = $splitAmount.val();
		}
		else if($fundAmount.is(':visible'))
		{
			//Until we decide what to do with this
			$value = 0;
		}

		/* --- PayPal 2.9% + 30 cent static --- */
		//Calculate fee
		$paypalFee = (0.029 * $value);
		$paypalFee += 0.30;

		//Update display
		$paypalField.val($paypalFee.toMoney());

		/* --- WePay 2.9% + 30 cent static --- */
		//Calculate fee
		$wepayFee = (0.029 * $value);
		$wepayFee += 0.30;

		//Update display
		$wepayField.val($wepayFee.toMoney());

		/* --- Dwolla 25 cent static --- */
		//Calculate fee
		$dwollaFee = 0.25;

		//Update display
		$dwollaField.val($dwollaFee.toMoney());

		/* --- PWM 
		0 cents for <$10 
		50 cents for <$30
		1$ for <$50
		2$ for >$50 --- */
		if($value < 10.00)
		{
			$pwmFee = 0.0;
		}
		else if($value < 30.00)
		{
			$pwmFee = 0.50;
		}
		else if($value < 50.00)
		{
			$pwmFee = 1.00;
		}
		else
		{
			$pwmFee = 2.00;
		}

		//Update PWM Display
		$pwmField.val($pwmFee.toMoney());
	}

	//If the dwolla payment button is clicked
	$("#allow-dwolla-payment").click(function(e)
	{

		if($dwollaFeeDiv.is(':visible'))
		{
			//Hide if visible
			$dwollaFeeDiv.hide();
			$numFieldsVisible --;

			//If all others hidden, hide pwm
			if($numFieldsVisible == 0)
			{
				$pwmFeeDiv.hide();
			}
		}
		else
		{
			//Show if not visible with proper calculations
			$dwollaFeeDiv.fadeIn();
			$pwmFeeDiv.fadeIn();
			$numFieldsVisible ++;
			calculateFees();
		}
	});

	//If the paypal payment button is clicked
	$("#allow-paypal-payment").click(function(e)
	{
		if($paypalFeeDiv.is(':visible'))
		{
			//Hide if visible
			$paypalFeeDiv.hide();
			$numFieldsVisible --;

			//If all others hidden, hide pwm
			if($numFieldsVisible == 0)
			{
				$pwmFeeDiv.hide();
			}
		}
		else
		{
			//Show if not visible with proper calculations
			$paypalFeeDiv.fadeIn();
			$pwmFeeDiv.fadeIn();
			$numFieldsVisible ++;
			calculateFees();
		}
	});

	//If the wepay payment button is clicked
	$("#allow-wepay-payment").click(function(e)
	{
		if($wepayFeeDiv.is(':visible'))
		{
			//Hide if visible
			$wepayFeeDiv.hide();
			$numFieldsVisible --;

			//If all others hidden, hide pwm
			if($numFieldsVisible == 0)
			{
				$pwmFeeDiv.hide();
			}
		}
		else
		{
			//Show if not visible with proper calculations
			$wepayFeeDiv.fadeIn();
			$pwmFeeDiv.fadeIn();
			$numFieldsVisible ++;
			calculateFees();
		}
	});

	//Recalculate if the payment type buttons are clicked
	$totalButton.click(function(e)
	{
		calculateFees();
	});

	$splitButton.click(function(e)
	{
		calculateFees();
	});

	$fundButton.click(function(e)
	{
		calculateFees();
	})
});