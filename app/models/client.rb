class Client < ApplicationRecord
  validates :name, :email, presence: true
  validates :name, uniqueness: true

  has_one :account
end
