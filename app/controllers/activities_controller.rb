class ActivitiesController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped

  def index
    authorize Activity
    @activities = policy_scope(Activity).includes(:user, stay: :user).order(created_at: :desc).limit(50)
  end
end
