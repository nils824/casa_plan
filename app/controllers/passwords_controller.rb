class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_password_path, alert: "Zu viele Versuche. Bitte später erneut versuchen." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Falls ein Konto mit dieser E-Mail-Adresse existiert, wurde eine Anleitung verschickt."
  end

  def edit
  end

  def update
    if params[:password].present? && @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Das Passwort wurde zurückgesetzt."
    else
      message = @user.errors.any? ? @user.errors.full_messages.to_sentence : "Bitte ein neues Passwort eingeben."
      redirect_to edit_password_path(params[:token]), alert: message
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Der Link ist ungültig oder abgelaufen."
    end
end
