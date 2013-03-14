Paperclip::Attachment.default_options.update({
  styles:
  {
    thumb: "#{Figaro.env.thumb_size}x#{Figaro.env.thumb_size}>",
    small: "#{Figaro.env.small_size}x#{Figaro.env.small_size}>",
    medium: "#{Figaro.env.medium_size}x#{Figaro.env.medium_size}>",
    large: "#{Figaro.env.large_size}x#{Figaro.env.large_size}>",
    full: "#{Figaro.env.full_size}x#{Figaro.env.full_size}>"
  },
  storage: :fog,
  fog_credentials:
  {
    provider: "Rackspace",
    rackspace_username: Figaro.env.rackspace_username,
    rackspace_api_key: Figaro.env.rackspace_key,
    rackspace_region: :ord
  },
  fog_directory: "uploaded-images",
  fog_host: "http://755d67cfc17f419ac9b7-b6e49b6274b073a668d3a9c93161275e.r50.cf2.rackcdn.com"
})