class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def pundit_user
    Current.user
  end

  # Shows a message that depends on the denied policy method, see config/locales/de.yml (pundit).
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    message = t("#{policy_name}.#{exception.query}", scope: :pundit, default: :default)
    redirect_back_or_to root_path, alert: message
  end
end
