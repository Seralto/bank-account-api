class Account < ApplicationRecord
  validates :client, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: true

  belongs_to :client
end
