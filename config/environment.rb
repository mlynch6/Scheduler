# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Scheduler::Application.initialize!
Time::DATE_FORMATS[:hr12] = "%l:%M %p"
Time::DATE_FORMATS[:dayofweek] = "%A"
Faker::Config.locale = :en