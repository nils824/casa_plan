class StayPolicy < ApplicationPolicy
  # All family members see the whole occupancy plan.
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  # The form is only offered for open requests.
  def edit?
    owner_or_manager? && record.requested?
  end

  # Whether the request is still open is checked by the model (validation and
  # optimistic locking), so a user whose form became outdated keeps the input.
  def update?
    owner_or_manager?
  end

  def withdraw?
    owner_or_manager? && record.requested?
  end

  def confirm?
    manager?
  end

  def reject?
    manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.all : scope.none
    end
  end

  private

  def manager?
    user.present? && user.manager?
  end

  def owner_or_manager?
    manager? || record.owned_by?(user)
  end
end
