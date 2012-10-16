module ApplicationHelper
    def avatar_url(user, options = {})
        #if user.image.present?
        #  user.image
        #else
            size = options[:size] || 250
            default_url = root_url + asset_path("guest.png")
            gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
            "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=#{CGI.escape(default_url)}"
        #end
    end

    # Returns the full title on a per-page basis.
    def full_title(page_title)
        base_title = "PayWithMe"

        if page_title.empty?
            base_title
        else
            "#{page_title}"
        end
    end
end