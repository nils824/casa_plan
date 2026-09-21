class EmailChangeMailer < ApplicationMailer
  def confirm(user)
    @user = user
    @link = email_confirmation_url(user.email_confirmation_token)
    Rails.logger.info "E-Mail-Bestätigungslink für #{user.unconfirmed_email}: #{@link}"
    mail subject: "CasaPlan: Neue E-Mail-Adresse bestätigen", to: user.unconfirmed_email
  end
end
