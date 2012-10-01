Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, "sPoEsKdwXGoQojMlooJfBg", "7JK4A5t9AmVgLvekorTnW3uvhN0fSjOwjzFPs8Sbb4", strategy_class: OmniAuth::Strategies::Twitter
end