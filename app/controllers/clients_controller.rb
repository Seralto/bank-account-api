class ClientsController < ApplicationController
  include CurrencyHelper

  before_action :set_client, only: %i[show update destroy balance transfer_money]
  before_action :authenticate_request, except: :create
  before_action :check_user, :verify_amount_numericality, only: :transfer_money

  # GET /clients
  def index
    @clients = Client.all

    render json: @clients
  end

  # GET /clients/1
  def show
    render json: @client
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      render json: @client, status: :created, location: @client
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      render json: @client
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
  end

  # GET /clients/1/balance
  def balance
    if @client.account
      render json: { current_balance: format_currency(@client.account.balance) }
    else
      render json: { error: 'Account does not exist.' }, status: :not_found
    end
  end

  # GET /clients/1/transfer_money
  def transfer_money
    res = TransferMoneyService.new(params).perform

    if res[:success]
      render json: {
        amount_transferred: format_currency(params[:amount]),
        current_balance: format_currency(@client.account.balance)
      }
    else
      render json: { error: res[:message] }, status: :bad_request
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :password, :password_confirmation)
  end

  def check_user
    if @current_user.id != @client.id
      render json: { error: 'Transfer not allowed' }, status: :forbidden
    end
  end

  def verify_amount_numericality
    unless params[:amount].is_a? Numeric
      render json: { error: 'Amount is not a number' }, status: :bad_request
    end
  end
end
