# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Scheduler::Application.initialize!
Time::DATE_FORMATS[:mil_date] = "%d%b%Y"
Time::DATE_FORMATS[:hr12] = "%I:%M %p"
Faker::Config.locale = :en