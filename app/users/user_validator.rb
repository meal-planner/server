class UserValidator
  include Veto.validator

  validates :display_name, presence: true
  validates :email, presence: true
  validates :password, presence: true
end