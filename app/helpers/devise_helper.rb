module DeviseHelper
  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  def devise_error_messages!
    devise_error_messages(resource.errors)
  end

  def devise_error_messages(errors)
    return "" if !errors || errors.empty?

    messages = errors.full_messages.join('<br />')
    sentence = I18n.t("errors.messages.not_saved", :count => errors.count, :resource => "user")

    html = <<-HTML
    <div class="alert alert-error">
      <strong>#{sentence}</strong><br />
      #{messages}
    </div>
    HTML

    html.html_safe
  end
end