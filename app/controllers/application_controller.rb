class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
# sessions_helper is in helpers/
# everything in helpers/ is available to everything in views/ by default
# this 'include' line makes helpers/sessions_helper available in here
# it also make helpers/sessions_helper available to other files in controllers/
# b/c sessions_helper is used in sessions_controller, but 
# does not have the line 'include SessionsHelper'

end
