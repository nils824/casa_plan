class UserPolicy < ApplicationPolicy
  def index?
    manager?
  end

  def update?
    manager?
  end

  # A manager may not change their own role, so the family never ends up
  # without a manager by accident.
  def permitted_attributes
    if record == user
      %i[name email_address]
    else
      %i[name email_address role]
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? && user.manager? ? scope.all : scope.none
    end
  end

  private

  def manager?
    user.present? && user.manager?
  end
end
