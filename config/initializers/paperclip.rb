Paperclip::Attachment.default_options[:styles] = {
  thumb: "#{Figaro.env.thumb_size}x#{Figaro.env.thumb_size}>",
  small: "#{Figaro.env.small_size}x#{Figaro.env.small_size}>",
  medium: "#{Figaro.env.medium_size}x#{Figaro.env.medium_size}>",
  large: "#{Figaro.env.large_size}x#{Figaro.env.large_size}>",
  full: "#{Figaro.env.full_size}x#{Figaro.env.full_size}>"
}