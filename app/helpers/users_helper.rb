module UsersHelper
  def profile_image_path(user, size=:thumb)
    if user.profile_image.present?
      user.profile_image.url(size)
    elsif user.profile_image_url.present?
      user.profile_image_url
    end
  end

  def profile_image_tag(user, size=:thumb)
    width = Figaro.env.send(size.to_s+"_size")
    if user.profile_image.present? || user.profile_image_url.present?
      image = image_tag(profile_image_path(user, size), width: width)
    else
      image = gravatar_image_tag user.email, alt: user.name, gravatar: { size: width }
    end
    link_to image, user
  end

  def user_name(user, length=20)
    user.name || ( length > 0 ? user.email.truncate(20) : user.email )
  end

  def user_for_mustache(user)
    {
      id: user.id,
      stub: user.stub?,
      email: user.email,
      name: user_name(user, 0),
      profile_image_tag: profile_image_tag(user)
    }
  end

  def give_stub_default_name(stub_user)
    stub_user.name = stub_user.email.split('@').first
  end
end