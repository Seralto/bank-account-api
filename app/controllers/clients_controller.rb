class ClientsController < ApplicationController
  before_action :set_client, only: %i[show update destroy balance transfer_money]
  before_action :authenticate_request, except: :create

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
      render json: { current_balance: @client.account.balance }
    else
      render json: { error: 'Account does not exist.' }, status: :not_found
    end
  end

  def transfer_money
    res = TransferMoneyService.new(params).perform

    if res[:success]
      render json: @client.account
    else
      render json: { error: res[:message] }, status: :unprocessable_entity
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :password, :password_confirmation)
  end
end
