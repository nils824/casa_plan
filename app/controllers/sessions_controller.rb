class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Zu viele Versuche. Bitte später erneut versuchen." }

  def new
  end

  def create
    # authenticate_by takes the same time whether the address exists or not
    # (protection against timing-based user enumeration).
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "E-Mail-Adresse oder Passwort ist falsch."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Du wurdest abgemeldet."
  end
end
