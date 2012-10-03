module ApplicationHelper
  def avatar_url(user, options = {})
    #if user.image.present?
    #  user.image
    #else
      size = options[:size] || 250
      default_url = "#{root_url}images/guest.png"
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
    #end
  end
end