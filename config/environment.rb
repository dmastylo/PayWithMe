# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PayWithMe::Application.initialize!

# Change some date formats
date_format = '%m/%d/%Y'
time_format = date_format + ' %I:%M%p'
Time::DATE_FORMATS[:default] = time_format
Date::DATE_FORMATS[:default] = date_format