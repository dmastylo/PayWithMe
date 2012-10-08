Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, "sPoEsKdwXGoQojMlooJfBg", "7JK4A5t9AmVgLvekorTnW3uvhN0fSjOwjzFPs8Sbb4", strategy_class: OmniAuth::Strategies::Twitter
  provider :facebook, "141836152608292", "b34af2003a66f9e3a6b4c6a3ab6ad701"
end