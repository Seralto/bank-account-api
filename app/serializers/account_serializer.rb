class AccountSerializer < ActiveModel::Serializer
  attributes :id, :client_id, :balance, :created_at

  def balance
    object.balance.to_f
  end
end
