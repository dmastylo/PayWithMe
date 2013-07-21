require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, "106307611472.apps.googleusercontent.com", "l5803dLn1Pc3BwFpusqJ2VmD", { :redirect_path => "/contacts_callback" }, :max_results => 5000 # :ssl_ca_file => "/etc/ssl/certs/curl-ca-bundle.crt"
end