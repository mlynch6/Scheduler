# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Scheduler::Application.initialize!
Time::DATE_FORMATS[:hr12] = "%-l:%M %p"
Time::DATE_FORMATS[:hr24] = "%H:%M"
Time::DATE_FORMATS[:full] = "%-m/%-d/%Y %-l:%M %p"
Time::DATE_FORMATS[:date_words] = "%B %-d, %Y"
Time::DATE_FORMATS[:dayofweek] = "%A"

Date::DATE_FORMATS[:default] = "%m/%d/%Y"
Date::DATE_FORMATS[:date_words] = "%B %-d, %Y"
Date::DATE_FORMATS[:dayofweek] = "%A"