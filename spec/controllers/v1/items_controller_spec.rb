require 'rails_helper'

describe V1::ItemsController do
  describe 'POST #create' do
    let(:item_type) { create :item_type }
    let(:submit) do
      post :create, name: name,
                    item_type_uuid: item_type.uuid,
                    reservable: true
    end
    let(:name) { 'Gillig' }
    context 'write access to item type' do
      before(:each) { authenticate_with_access_to :write, item_type }
      context 'item created successfully' do
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'returns the created item' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'uuid' => Item.last.uuid,
            'name' => 'Gillig',
            'reservable' => true,
            'item_type' => { 'uuid' => item_type.uuid },
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
    context 'no write access to item type' do
      before(:each) { authenticate_with_access_to :read, item_type }
      it 'has an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:submit) { delete :destroy, id: item.uuid }
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
      let(:item) { double uuid: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let(:item) { create :item }
    let(:submit) { get :index, item_type_uuid: item.item_type.uuid }
    context 'read access to item type' do
      before(:each) { authenticate_with_access_to :read, item.item_type }
      it 'renders all items' do
        submit
        json = JSON.parse response.body
        expect(json).to eql [{
          'uuid' => item.uuid,
          'name' => item.name,
          'reservable' => item.reservable,
          'item_type' => { 'uuid' => item.item_type.uuid },
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
    let(:submit) { get :show, id: item.uuid }
    context 'item found' do
      let(:item) { create :item }
      context 'read access to item type' do
        before(:each) { authenticate_with_access_to :read, item.item_type }
        it 'includes item attributes' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'uuid' => item.uuid,
            'name' => item.name,
            'reservable' => item.reservable,
            'item_type' => { 'uuid' => item.item_type.uuid },
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
      let(:item) { double uuid: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PUT #update' do
    let(:changes) { { reservable: false } }
    let(:submit) { put :update, id: item.uuid, item: changes }
    context 'item found' do
      let(:item_type) { create :item_type, allowed_keys: [:color] }
      let(:item) { create :item, item_type: item_type }
      context 'write access to item type' do
        # authenticate_with_access_to returns the service as which you
        # are authenticated - so here we assign it to a variable so
        # we can add more permissions
        let!(:service) { authenticate_with_access_to :write, item_type }
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
          it 'responds with the new attributes' do
            submit
            item.reload
            json = JSON.parse response.body
            expect(json).to eql({
              "uuid" => item.uuid,
              "name" => item.name,
              "reservable" => item.reservable,
              "data" => item.data,
              "item_type" => { "uuid" => item_type.uuid }
            })
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
        context 'changing item type' do
          let(:new_item_type) { create :item_type }
          let(:changes) { { item_type_id: new_item_type.id } }
          context 'write access to new item type' do
            before :each do
              # add another permission to the service which already has
              # write access to the item's original type
              create :permission, item_type: new_item_type, service: service,
                                  write: true
            end
            it 'has an OK status' do
              submit
              expect(response).to have_http_status :ok
            end
          end
          context 'no write access to new item type' do
            it 'has an unauthorized status' do
              submit
              expect(response).to have_http_status :unauthorized
            end
            it 'has a message explaining the failure' do
              message = 'You do not have write access to the new item type'
              submit
              json = JSON.parse response.body
              expect(json).to eql 'message' => message
            end
          end
        end
      end
      context 'no write access to item type' do
        before(:each) { authenticate_with_access_to :read, item_type }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'item not found' do
      let(:item) { double uuid: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
