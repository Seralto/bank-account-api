class AccountSerializer < ActiveModel::Serializer
  include CurrencyHelper

  attributes :id, :client_id, :balance, :created_at

  def balance
    format_currency(object.balance)
  end
end
