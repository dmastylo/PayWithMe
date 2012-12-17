module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "PayWithMe"

    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  # Returns Submit or Create depending if the object is saved
  def submit_text(object)
    if object.persisted?
      "Update"
    else
      "Create"
    end
  end

  # Returns params for ?guest_token=... if applicable
  def guest_params(user)
    if user.stub?
      { token: user.guest_token }
    else
      {}
    end
  end
end
