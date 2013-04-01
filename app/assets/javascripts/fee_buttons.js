$(document).ready(function()
{

	var $dwollaFeeDiv = $("#dwolla-fee");
	var $allFeeDiv = $("#all-fee");

	var $dwollaField = $("#dwolla-fee-field");
	var $allField = $("#all-fee-field");

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

	//Currently should do nothing if fundraiser is selected (needs donation amount)

	//For total, should split total between all members added to the event
	//For amount, should just calculate based on that value

	function calculateFees(){

		var $value = 0;
		var $dwollaFee = 0;
		var $allFee = 0;
		var $members = 0;

		//Determine value owed per person
		if($totalAmount.is(':visible'))
		{
			$value = $totalAmount.val();

			$members = $('.member').length;
			if($members == 0) $members = 1;

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

		/* --- Dwolla $0.25 static if greater than $10 --- */
		//Calculate fee
		if($value > 10)
		{
			$dwollaFee = 0.25;
		}
		else
		{
			$dwollaFee = 0.00;
		}

		//Update display
		$dwollaField.val($dwollaFee.toMoney());

		/* --- All others 4.0% + $0.50 --- */
		$allFee = $value * .04;
		$allFee += .5;

		//Update display
		$allField.val($allFee.toMoney());
	}

	//If the dwolla payment button is clicked
	$("#calculate-fee-dwolla").click(function(e)
	{

		if($dwollaFeeDiv.is(':visible'))
		{
			//Hide if visible
			$dwollaFeeDiv.hide();
		}
		else
		{
			//Show if not visible with proper calculations
			$dwollaFeeDiv.fadeIn();
			calculateFees();
		}
	});

	//If the PayPal or WePay payment button is clicked
	$("#calculate-fee-wepay").click(function(e)
	{
		if($("#calculate-fee-paypal").hasClass('active'))
		{
		}
		else
		{
			if($allFeeDiv.is(':visible'))
			{
				//Hide if visible
				$allFeeDiv.hide();
			}
			else
			{
				//Show if not visible with proper calculations
				$allFeeDiv.fadeIn();
				calculateFees();
			}
		}
	});

	$("#calculate-fee-paypal").click(function(e)
	{
		if($("#calculate-fee-wepay").hasClass('active'))
		{
		}
		else
		{
			if($allFeeDiv.is(':visible'))
			{
				//Hide if visible
				$allFeeDiv.hide();
			}
			else
			{
				//Show if not visible with proper calculations
				$allFeeDiv.fadeIn();
				calculateFees();
			}
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