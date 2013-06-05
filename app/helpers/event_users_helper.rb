module EventUsersHelper
  def event_user_pay_button(event_user, payment_method)
    path = pay_event_user_path(@event_user, method: PaymentMethod::MethodType.const_get(payment_method.upcase))
    link_to event_user_pay_text(event_user, payment_method), path, class: "btn btn-primary btn-block push-bottom"
  end

  def event_user_pay_fundraiser_button(event_user, payment_method)
    path = pay_fundraiser_event_user_path(@event_user, method: PaymentMethod::MethodType.const_get(payment_method.upcase), amount_cents: @event_user.amount_cents || 0)
    link_to event_user_pay_text(event_user, payment_method), path, id: "pay_with_#{payment_method.downcase}_link", class: "payment-link btn btn-primary btn-block push-bottom"
  end

  def event_user_pay_text(event_user, payment_method, options={})
    if options[:fundraiser]
      payment_verb = "Contribute"
    else
      payment_verb = "Pay"
    end
    "#{payment_verb} <span class=\"pay-total\">#{humanized_money_with_symbol event_user.event.split}</span> With Credit or Debit Card".html_safe
  end
end