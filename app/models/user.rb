class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :stays, dependent: :restrict_with_error
  has_many :decided_stays, class_name: "Stay", foreign_key: :decided_by_id,
                           inverse_of: :decided_by, dependent: :nullify
  has_many :activities, dependent: :restrict_with_error

  enum :role, { member: "member", manager: "manager" }, default: :member, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :unconfirmed_email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, allow_nil: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validate :unconfirmed_email_available, if: -> { unconfirmed_email.present? }

  def role_label
    I18n.t(role, scope: "user_roles")
  end

  # Step 1 of the e-mail change: remember the new address and a random token.
  # The address itself only changes once the link has been confirmed.
  def request_email_change(new_email)
    self.unconfirmed_email = new_email.to_s
    self.email_confirmation_token = SecureRandom.urlsafe_base64(32)
    save
  end

  # Step 2: the user opened the confirmation link.
  def confirm_email_change!
    update!(email_address: unconfirmed_email, unconfirmed_email: nil, email_confirmation_token: nil)
  end

  private

  def unconfirmed_email_available
    if unconfirmed_email == email_address_in_database
      errors.add(:unconfirmed_email, "entspricht der aktuellen E-Mail-Adresse")
    elsif User.where.not(id: id).exists?(email_address: unconfirmed_email)
      errors.add(:unconfirmed_email, :taken)
    end
  end
end
