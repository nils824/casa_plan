class StaysController < ApplicationController
  before_action :set_stay, only: %i[show edit update withdraw confirm reject]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Stay
    stays = policy_scope(Stay).includes(:user).order(:arrival_on)

    @plan = stays.active.upcoming
    @own_stays = stays.where(user: Current.user).reorder(arrival_on: :desc).limit(10)
    @open_requests = stays.requested.upcoming if Current.user.manager?
  end

  def show
    authorize @stay
    load_activities
  end

  def new
    @stay = Stay.new(house: House.first)
    authorize @stay
  end

  def create
    @stay = Stay.new(new_stay_params.merge(house: House.first, user: Current.user))
    authorize @stay

    if @stay.save_with_activity(actor: Current.user, event: "requested")
      redirect_to @stay, notice: "Deine Anfrage wurde gesendet. Der Verwalter entscheidet darüber."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @stay
  end

  def update
    authorize @stay
    @stay.assign_attributes(edit_stay_params)

    if @stay.save_with_activity(actor: Current.user, event: "updated")
      redirect_to @stay, notice: "Anfrage gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    # Someone else changed the request after the form was opened (optimistic locking).
    # The input stays in the form; the version is updated so the user can save again on purpose.
    @stay.lock_version = Stay.where(id: @stay.id).pick(:lock_version)
    @stay.errors.add(:base, "Diese Anfrage wurde inzwischen von jemand anderem geändert. " \
                            "Deine Eingaben sind noch vorhanden. Prüfe sie und speichere erneut.")
    render :edit, status: :conflict
  end

  def withdraw
    authorize @stay

    if @stay.withdraw_by(Current.user)
      redirect_to @stay, notice: "Anfrage zurückgezogen."
    else
      render_show_with_errors
    end
  end

  def confirm
    authorize @stay

    if @stay.confirm_by(Current.user)
      redirect_to @stay, notice: "Aufenthalt bestätigt."
    else
      render_show_with_errors
    end
  end

  def reject
    authorize @stay

    if @stay.reject_by(Current.user, params.dig(:stay, :rejection_reason))
      redirect_to @stay, notice: "Anfrage abgelehnt."
    else
      render_show_with_errors
    end
  end

  private

  def set_stay
    @stay = Stay.find(params[:id])
  end

  def load_activities
    @activities = @stay.activities.includes(:user).order(created_at: :desc)
  end

  def render_show_with_errors
    load_activities
    render :show, status: :unprocessable_entity
  end

  def new_stay_params
    params.expect(stay: [ :arrival_on, :departure_on, :guests_count, :note ])
  end

  def edit_stay_params
    params.expect(stay: [ :arrival_on, :departure_on, :guests_count, :note, :lock_version ])
  end
end
