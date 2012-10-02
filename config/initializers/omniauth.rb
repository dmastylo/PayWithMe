Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, "sPoEsKdwXGoQojMlooJfBg", "7JK4A5t9AmVgLvekorTnW3uvhN0fSjOwjzFPs8Sbb4", strategy_class: OmniAuth::Strategies::Twitter
  provider :facebook, "161030761540", "3c2a573d106ed2cfa9967a90a22189a4"
end