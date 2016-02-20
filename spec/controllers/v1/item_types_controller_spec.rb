require 'rails_helper'

describe V1::ItemTypesController do
  describe 'POST #create' do
    let(:submit) { post :create, name: name, allowed_keys: allowed_keys }
    let(:name) { 'Buses' }
    let(:allowed_keys) { %w(color length) }
    let(:other_item_type) { create :item_type }
    context 'write access to another item_type' do
      before(:each) { authenticate_with_access_to :write, other_item_type }
      context 'item type created successfully' do
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'returns the created item type' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'id' => other_item_type.id + 1,
            'name' => 'Buses',
            'allowed_keys' => allowed_keys,
            'items' => [])
        end
      end
      context 'error creating item type' do
        let(:name) { ' ' }
        let(:error_messages) { ["Name can't be blank"] }
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'returns the errors of the item type' do
          submit
          json = JSON.parse response.body
          expect(json).to eql 'errors' => error_messages
        end
      end
    end
    context 'read access to another item_type' do
      before(:each) { authenticate_with_access_to :read, other_item_type }
      it 'has an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:submit) { delete :destroy, id: item_type.id }
    context 'item type found' do
      let(:item_type) { create :item_type }
      context 'write access' do
        before(:each) { authenticate_with_access_to :write, item_type }
        it 'deletes the item type' do
          submit
          expect(ItemType.count).to be 0
        end
        it 'deletes any items belonging to the item type' do
          create :item, item_type: item_type
          submit
          expect(Item.count).to be 0
        end
        it 'has on OK status' do
          submit
          expect(response).to have_http_status :ok
        end
      end
      context 'read access' do
        before(:each) { authenticate_with_access_to :read, item_type }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'item type not found' do
      let(:item_type) { double id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let(:submit) { get :index }
    let(:item_type) { create :item_type }
    let!(:item_1) { create :item, item_type: item_type }
    let!(:item_2) { create :item, item_type: item_type }
    before(:each) { authenticate_with_access_to :read, item_type }
    let!(:inaccessible_item_type) { create :item_type }
    it 'renders all read-accessible item types' do
      submit
      expect(response.body).not_to include inaccessible_item_type.name
      json = JSON.parse response.body
      expect(json).to eql(
        [{ 'id' => item_type.id,
           'name' => item_type.name,
           'allowed_keys' => item_type.allowed_keys.map(&:to_s),
           'items' => [{ 'name' => item_1.name },
                       { 'name' => item_2.name }] }])
    end
  end

  describe 'GET #show' do
    let(:submit) { get :show, id: item_type.id }
    context 'item type found' do
      let(:item_type) { create :item_type }
      let!(:item_1) { create :item, item_type: item_type }
      let!(:item_2) { create :item, item_type: item_type }
      context 'read access to item type' do
        before(:each) { authenticate_with_access_to :read, item_type }
        it 'includes item type and item attributes' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'id' => item_type.id,
            'name' => item_type.name,
            'allowed_keys' => item_type.allowed_keys.map(&:to_s),
            'items' => [{ 'id' => item_1.id,
                          'name' => item_1.name },
                        { 'id' => item_2.id,
                          'name' => item_2.name }])
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
    context 'item type not found' do
      before(:each) { authenticate! }
      let(:item_type) { double id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PUT #update' do
    let(:changes) { { name: 'A new name' } }
    let(:submit) { put :update, id: item_type.id, item_type: changes }
    context 'item type found' do
      let(:item_type) { create :item_type }
      context 'write access' do
        before(:each) { authenticate_with_access_to :write, item_type }
        context 'change applied successfully' do
          it 'calls #update on the item type with the changes' do
            expect_any_instance_of(ItemType)
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
          let(:changes) { { name: nil } }
          let(:error_messages) { ["Name can't be blank"] }
          it 'has an unprocessable entity status' do
            submit
            expect(response).to have_http_status :unprocessable_entity
          end
          it 'responds with an object containing the item type errors' do
            submit
            json = JSON.parse response.body
            expect(json).to eql 'errors' => error_messages
          end
        end
      end
      context 'read access' do
        before(:each) { authenticate_with_access_to :read, item_type }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'item type not found' do
      let(:item_type) { double id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
