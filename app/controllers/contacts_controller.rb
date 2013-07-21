class ContactsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :user_owns_contact, only: [:destroy]

  def index
    @contacts = current_user.contacts
  end

  def create
    @added_contacts = params[:contact]
    @added_contacts.each do |contact|
      name = contact[1].split(",")[0].strip
      email = contact[1].split(",")[1].strip
      current_user.contacts.create(name: name, email: email) if current_user.contacts.find_by_email(email).blank?
    end

    flash.now[:success] = "Added #{@added_contacts.size} contacts!"

    @contacts = current_user.contacts
  end

  def destroy
    @contact.destroy
    flash[:success] = "Contact deleted!"
    redirect_to contacts_path
  end

private

  def user_owns_contact
    @contact = current_user.contacts.find(params[:id] || params[:contact_id])
    redirect_to contacts_path if @contact.nil?
  end

end
