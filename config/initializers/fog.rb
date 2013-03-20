Fog::Storage::Rackspace.class_eval do
  recognizes :rackspace_storage_url
end

Fog::Storage::Rackspace::Real.class_eval do
  private
  def authenticate_with_chain
    authenticate_without_chain
    if (new_host = @rackspace_storage_url).present?
      @host = @rackspace_servicenet == true ? "snet-#{new_host}" : new_host
    end
  end
  alias_method_chain :authenticate, :chain
end