class Client < ApplicationRecord
  validates :name, :email, presence: true
  validates :name, uniqueness: true
end
