class Profile::EmailsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.request_email_change(params.dig(:user, :unconfirmed_email))
      # Sent only after the change request was saved successfully.
      # A sent e-mail cannot be rolled back, so it must not be part of the transaction.
      EmailChangeMailer.confirm(@user).deliver_later
      redirect_to profile_path, notice: "Wir haben einen Bestätigungslink an #{@user.unconfirmed_email} gesendet."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end
end
