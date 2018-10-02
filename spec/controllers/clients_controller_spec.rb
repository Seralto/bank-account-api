require 'rails_helper'

include CurrencyHelper

RSpec.describe ClientsController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:check_user).and_return(true)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      create(:client)
      get :index, params: {}

      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      client = create(:client)
      get :show, params: { id: client.to_param }
      json = JSON.parse(response.body)

      expect(response).to be_successful
      expect(json['name']).to eq(client.name)
      expect(json['email']).to eq(client.email)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Client' do
        expect do
          post :create, params: { client: attributes_for(:client) }
        end.to change(Client, :count).by(1)
      end

      it 'renders a JSON response with the new client' do
        post :create, params: { client: attributes_for(:client) }

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(client_url(Client.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new client' do
        post :create, params: { client: attributes_for(:client).merge(name: nil) }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested client' do
        client = create(:client)
        put :update, params: { id: client.to_param, client: { name: 'New name' } }
        client.reload

        expect(client.name).to eq('New name')
      end

      it 'renders a JSON response with the client' do
        client = create(:client)
        put :update, params: { id: client.to_param, client: { name: 'New name' } }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the client' do
        client = create(:client)
        put :update, params: { id: client.to_param, client: { name: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested client' do
      client = create(:client)

      expect do
        delete :destroy, params: { id: client.to_param }
      end.to change(Client, :count).by(-1)
    end
  end

  describe 'GET #balance' do
    context 'with valid account' do
      it 'renders a JSON response with the current balance' do
        client = create(:client)
        account = create(:account, client: client)

        get :balance, params: { id: client.to_param }
        json = JSON.parse(response.body)

        expect(response).to be_successful
        expect(json['current_balance']).to eq(format_currency(account.balance))
      end
    end

    context 'with invalid account' do
      it 'renders a JSON response with an error' do
        client = create(:client)

        get :balance, params: { id: client.to_param }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #transfer_money' do
    context 'with sufficient balance' do
      it 'transfer the money amount' do
        source_account = create(:account, balance: 1000.00)
        destination_account = create(:account, balance: 1000.00)

        post :transfer_money, params: {
          id: source_account.client.to_param,
          destination_account_id: destination_account.to_param,
          amount: 800.00
        }, as: :json

        source_account.reload
        destination_account.reload

        expect(response).to be_successful
        expect(format_currency(source_account.balance)).to eq(format_currency(200))
        expect(format_currency(destination_account.balance)).to eq(format_currency(1800))
      end
    end

    context 'with insufficient balance' do
      it 'renders a JSON response with an error' do
        source_account = create(:account, balance: 0.00)
        destination_account = create(:account, balance: 1000.00)

        post :transfer_money, params: {
          id: source_account.client.to_param,
          destination_account_id: destination_account.to_param,
          amount: 500.00
        }, as: :json

        source_account.reload
        destination_account.reload

        expect(response).to have_http_status(:bad_request)
        expect(format_currency(source_account.balance)).to eq(format_currency(0))
        expect(format_currency(destination_account.balance)).to eq(format_currency(1000))
      end
    end

    context 'with invalid params' do
      it 'renders an error when source account does not exist' do
        destination_account_id = create(:account, balance: 1000.00)

        post :transfer_money, params: {
          id: 1111,
          destination_account_id: destination_account_id.to_param,
          amount: 500.00
        }, as: :json

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq("Couldn't find Client with 'id'=1111")
      end

      it 'renders an error when destination account does not exist' do
        source_account = create(:account, balance: 1000.00)

        post :transfer_money, params: {
          id: source_account.client.to_param,
          destination_account_id: 4321,
          amount: 500.00
        }, as: :json

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json['error']).to eq("Couldn't find Account with 'id'=4321")
      end

      it 'renders an error when amount is not a number' do
        source_account = create(:account, balance: 1000.00)
        destination_account = create(:account, balance: 1000.00)

        post :transfer_money, params: {
          id: source_account.client.to_param,
          destination_account_id: destination_account.to_param,
          amount: '500.00'
        }, as: :json

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json['error']).to eq('Amount is not a number')
      end
    end
  end
end
