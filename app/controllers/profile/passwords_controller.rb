class Profile::PasswordsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    # password_challenge is checked by has_secure_password. It is always set
    # (also when the field is missing), so the current password cannot be skipped.
    @user.password_challenge = password_params[:password_challenge].to_s
    @user.password = password_params[:password]
    @user.password_confirmation = password_params[:password_confirmation]

    if password_params[:password].blank?
      @user.errors.add(:password, :blank)
      return render(:edit, status: :unprocessable_entity)
    end

    # New password and ending all other sessions belong together.
    User.transaction do
      @user.save!
      @user.sessions.where.not(id: Current.session.id).destroy_all
    end

    redirect_to profile_path, notice: "Passwort geändert. Andere Sitzungen wurden abgemeldet."
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  private

  def set_user
    @user = Current.user
  end

  def password_params
    params.expect(user: [ :password_challenge, :password, :password_confirmation ])
  end
end
