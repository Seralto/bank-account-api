class TransferMoneyService
  attr_accessor :source_account_id, :destination_account_id, :amount

  def initialize(params)
    @source_account_id = params['id']
    @destination_account_id = params['destination_account_id']
    @amount = params['amount'].to_f
  end

  def perform
    source_account = Account.find(source_account_id)
    return { success: false, message: 'Not enough money.' } if source_account.balance < amount

    destination_account = Account.find(destination_account_id)

    Client.transaction do
      source_account.update!(balance: source_account.balance - amount)
      destination_account.update!(balance: destination_account.balance + amount)

      { success: true, message: 'Transfer completed.' }
    end
  rescue StandardError => e
    { success: false, message: e }
  end
end
