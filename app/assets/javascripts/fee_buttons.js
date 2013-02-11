$(document).ready(function()
{
	var $pwmFeeDiv = $("#paywithme-fee");
	var $paypalFeeDiv = $("#paypal-fee");
	var $dwollaFeeDiv = $("#dwolla-fee");

	var $pwmField = $("#paywithme-fee-field");
	var $paypalField = $("#paypal-fee-field");
	var $dwollaField = $("#dwolla-fee-field");

	var $totalAmount = $("#event_total_amount");
	var $splitAmount = $("#event_split_amount");

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
		var $pwmFee = 0;

		//Determine value owed per person
		if($totalAmount.is(':visible'))
		{
			$value = $totalAmount.val();

			//Need to determine amount of people in event *******************************************************************
		}
		else if($splitAmount.is(':visible'))
		{
			$value = $splitAmount.val();
		}


		/* --- PayPal 2.9% + 30 cent static --- */
		//Calculate fee
		$paypalFee = (0.029 * $value);
		$paypalFee += 0.30;

		//Update display
		$paypalField.val($paypalFee.toMoney());

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

			//If paypal is also hidden, hide pwm
			if(!$paypalFeeDiv.is(':visible'))
			{
				$pwmFeeDiv.hide();
			}
		}
		else
		{
			//Show if not visible with proper calculations
			$dwollaFeeDiv.fadeIn();
			$pwmFeeDiv.fadeIn();
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

			//If dwolla is also hidden, hide pwm
			if(!$dwollaFeeDiv.is(':visible'))
			{
				$pwmFeeDiv.hide();
			}
		}
		else
		{
			//Show if not visible with proper calculations
			$paypalFeeDiv.fadeIn();
			$pwmFeeDiv.fadeIn();
			calculateFees();
		}
	});
});