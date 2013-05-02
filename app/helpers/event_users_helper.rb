module EventUsersHelper
  def event_user_pay_button(event_user, payment_method)
  path = pay_event_user_path(@event_user, method: PaymentMethod::MethodType.const_get(payment_method.upcase))
  link_to event_user_pay_text(event_user, payment_method), path, class: "btn btn-primary btn-block push-bottom"
  end

  def event_user_pay_text(event_user, payment_method)
    if payment_method == "PayPal"
      payment_options = "Credit Card or PayPal Account"
    elsif payment_method == "WePay"
      payment_options = "Credit Card"
    elsif payment_method == "Dwolla"
      payment_options = "Dwolla Account"
    end
    "Pay <span class=\"items-total\">#{humanized_money_with_symbol event_user.event.split_amount}</span> With #{payment_options}".html_safe
  end
end