require 'rails_helper'

describe V1::ItemsController do
  describe 'POST #create' do
    let(:item_type) { create :item_type }
    let(:submit) do
      post :create, name: name,
                    item_type_id: item_type.id
    end
    context 'item created successfully' do
      let(:name) { 'Gillig' }
      it 'has an OK status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'returns the created item' do
        submit
        json = JSON.parse response.body
        expect(json).to eql(
          'id' => Item.last.id,
          'name' => 'Gillig',
          'item_type_id' => item_type.id,
          'data' => {})
      end
    end
    context 'error creating item' do
      let(:name) { ' ' }
      let(:error_messages) { ["Name can't be blank"] }
      it 'has an unprocessable entity status' do
        submit
        expect(response).to have_http_status :unprocessable_entity
      end
      it 'returns the errors of the item' do
        submit
        json = JSON.parse response.body
        expect(json).to eql 'errors' => error_messages
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:submit) { delete :destroy, id: item.id }
    context 'item found' do
      let(:item) { create :item }
      context 'write access to item type' do
        before(:each) { authenticate_with_access_to :write, item.item_type }
        it 'deletes the item' do
          submit
          expect(Item.count).to be 0
        end
        it 'has on OK status' do
          submit
          expect(response).to have_http_status :ok
        end
      end
      context 'no write access to item type' do
        before(:each) { authenticate_with_access_to :read, item.item_type }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'item not found' do
      let(:item) { double id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let(:item) { create :item }
    let(:submit) { get :index, item_type_id: item.item_type_id }
    context 'read access to item type' do
      before(:each) { authenticate_with_access_to :read, item.item_type }
      it 'renders all items' do
        submit
        json = JSON.parse response.body
        expect(json).to eql [{
          'id' => item.id,
          'name' => item.name,
          'item_type_id' => item.item_type_id,
          'data' => item.data }]
      end
    end
    context 'no read access to item type' do
      before(:each) { authenticate! }
      it 'has an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #show' do
    let(:submit) { get :show, id: item.id }
    context 'item found' do
      let(:item) { create :item }
      context 'read access to item type' do
        before(:each) { authenticate_with_access_to :read, item.item_type }
        it 'includes item attributes' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'id' => item.id,
            'name' => item.name,
            'item_type_id' => item.item_type_id,
            'data' => item.data)
        end
      end
      context 'no read access to item type' do
        before(:each) { authenticate! }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'item not found' do
      let(:item) { double id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PUT #update' do
    let(:changes) { { data: { color: 'green' } } }
    let(:submit) { put :update, id: item.id, item: changes }
    context 'item found' do
      let(:item_type) { create :item_type, allowed_keys: [:color] }
      let(:item) { create :item }
      context 'change applied successfully' do
        it 'calls #update on the item with the changes' do
          expect_any_instance_of(Item)
            .to receive(:update)
            .with(changes.stringify_keys)
            .and_call_original
          submit
        end
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'has an empty response body' do
          submit
          expect(response.body).to be_empty
        end
      end
      context 'change not applied successfully' do
        let(:changes) { { data: { length: 40 } } }
        let(:error_messages) { ['Disallowed key: length'] }
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'responds with an object containing the item errors' do
          submit
          json = JSON.parse response.body
          expect(json).to eql 'errors' => error_messages
        end
      end
    end
    context 'item not found' do
      let(:item) { double id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
