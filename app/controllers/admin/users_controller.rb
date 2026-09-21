class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[edit update]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User
    @users = policy_scope(User).order(:name)
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(permitted_attributes(@user))
      redirect_to admin_users_path, notice: "Benutzer «#{@user.name}» gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
