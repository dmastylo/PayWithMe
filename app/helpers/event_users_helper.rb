module EventUsersHelper
  def event_user_pay_button(event_user, payment_method)
    if payment_method == "Dwolla"
      path = pin_event_user_path(@event_user, method: PaymentMethod::MethodType.const_get(payment_method.upcase))
      method = :get
    else
      path = pay_event_user_path(@event_user, method: PaymentMethod::MethodType.const_get(payment_method.upcase))
      method = :post
    end
    link_to "Pay #{humanized_money_with_symbol event_user.event.split_amount} With #{payment_method}", path, class: "btn btn-primary btn-block push-bottom", method: method
  end
end