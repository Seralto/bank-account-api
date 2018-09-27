class Account < ApplicationRecord
  validates :client, :balance, presence: true
  validates :client, uniqueness: true

  belongs_to :client
end
