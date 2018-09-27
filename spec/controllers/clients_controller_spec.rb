require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
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
end
