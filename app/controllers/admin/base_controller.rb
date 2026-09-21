class Admin::BaseController < ApplicationController
  # Safety net: every admin action must call authorize.
  after_action :verify_authorized
end
