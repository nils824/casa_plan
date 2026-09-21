class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Zu viele Versuche. Bitte später erneut versuchen." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.valid?
    @user.errors.add(:base, "Der Einladungscode ist ungültig.") unless valid_invitation_code?

    if @user.errors.empty? && @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Willkommen bei CasaPlan!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
  end

  def valid_invitation_code?
    house = House.first
    code = params.dig(:user, :invitation_code).to_s

    house.present? && ActiveSupport::SecurityUtils.secure_compare(house.invitation_code, code)
  end
end