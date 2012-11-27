module UsersHelper
  def profile_image_path(user, size=:thumb)
    if user.profile_image.present?
      user.profile_image.url(size)
    elsif user.profile_image_url.present?
      user.profile_image_url
    else
      gravatar_image_tag user.email
    end
  end

  def profile_image_tag(user, size=:thumb)
    width = Figaro.env.send(size.to_s+"_size")
    image_tag profile_image_path(user, size), width: width
  end
end