class Client < ApplicationRecord
  validates :name, :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :name, uniqueness: true

  has_one :account

  has_secure_password
end
