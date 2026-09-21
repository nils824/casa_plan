# Singular resource: there is no id in the URL, the profile is always the one of
# the signed-in user. Other profiles cannot be requested at all.
class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profil gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def profile_params
    params.expect(user: [ :name ])
  end
end
