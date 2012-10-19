Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, "sPoEsKdwXGoQojMlooJfBg", "7JK4A5t9AmVgLvekorTnW3uvhN0fSjOwjzFPs8Sbb4"
  provider :facebook, "141836152608292", "b34af2003a66f9e3a6b4c6a3ab6ad701"
  provider :dwolla, "XV7LXC7tu3NlVe8qFcwKVJCIp9AmEzIXHUC2P6QOwu06H3i3Om", "U34SfFeKCYWvJ/xJzOJDW1iDlAgeZ/FXqkUepevRFdDvAaT7XO", scope: "accountinfofull|transactions|send", provider_ignores_state: true
end