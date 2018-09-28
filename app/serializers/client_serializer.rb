class ClientSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at

  has_one :account
end
