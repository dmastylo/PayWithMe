class ContactsController < ApplicationController
  # before_filter :authenticate_user!

  def create
    @contacts = params[:contact]
    @contacts.each do |contact|
      current_user.contacts.create(name: contact[1].split(",")[0], email: contact[1].split(",")[1])
    end
  end

end
