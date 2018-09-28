require 'rails_helper'

include CurrencyHelper

RSpec.describe AccountsController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
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
      account = create(:account)
      get :show, params: { id: account.to_param }
      json = JSON.parse(response.body)

      expect(response).to be_successful
      expect(json['balance']).to eq(format_currency(account.balance))
      expect(json['client_id']).to eq(account.client.id)
    end
  end

  describe 'POST #create' do
    let(:client) { create(:client) }

    context 'with valid params' do
      it 'creates a new Account' do
        expect do
          post :create, params: { account: attributes_for(:account).merge(client_id: client.to_param) }
        end.to change(Account, :count).by(1)
      end

      it 'renders a JSON response with the new account' do
        post :create, params: { account: attributes_for(:account).merge(client_id: client.to_param) }

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(account_url(Account.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new account' do
        post :create, params: { account: attributes_for(:account).merge(client_id: nil) }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_balance) { 1000.00 }

      it 'updates the requested account' do
        account = create(:account)
        put :update, params: { id: account.to_param, account: { balance: new_balance } }
        account.reload

        expect(account.balance).to eq(new_balance)
      end

      it 'renders a JSON response with the account' do
        account = create(:account)
        put :update, params: { id: account.to_param, account: { balance: new_balance } }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the account' do
        account = create(:account)
        put :update, params: { id: account.to_param, account: { balance: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested account' do
      account = create(:account)

      expect do
        delete :destroy, params: { id: account.to_param }
      end.to change(Account, :count).by(-1)
    end
  end
end
