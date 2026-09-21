class EmailConfirmationsController < ApplicationController
  allow_unauthenticated_access

  def show
    user = User.find_by(email_confirmation_token: params[:token].to_s)

    if user.nil? || user.unconfirmed_email.blank?
      redirect_to root_path, alert: "Der Bestätigungslink ist ungültig oder wurde bereits verwendet."
      return
    end

    user.confirm_email_change!
    redirect_to root_path, notice: "Deine E-Mail-Adresse wurde geändert."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    # Between request and confirmation another account may have taken this address.
    redirect_to root_path, alert: "Diese E-Mail-Adresse wird inzwischen von einem anderen Konto verwendet."
  end
end
