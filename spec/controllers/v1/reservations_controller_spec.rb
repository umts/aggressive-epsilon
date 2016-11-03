require 'rails_helper'

describe V1::ReservationsController do
  let!(:creator) { authenticate! }
  describe 'POST #create' do
    let(:item_type) { create :item_type }
    let(:item) { create :item, item_type: item_type }
    let :submit do
      post :create,
           item_type: item_type.name,
           start_time: default_start_time.iso8601,
           end_time: default_end_time.iso8601
    end
    let :submit_invalid_item_type_name do
      post :create,
           item_type: 'something that will never ever be created',
           start_time: default_start_time.iso8601,
           end_time: default_end_time.iso8601
    end
    context 'with available item' do
      let(:reservation) { create :reservation, item: item }
      before :each do
        expect_any_instance_of(ItemType)
          .to receive(:find_available)
          .with(default_start_time, default_end_time)
          .and_return item
        expect_any_instance_of(Item)
          .to receive(:reserve!)
          .with(from: default_start_time,
                to: default_end_time,
                creator: creator)
          .and_return reservation
      end
      it 'calls #reserve! on the item' do
        submit
      end
      it 'has an OK status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'responds with the created reservation' do
        submit
        json = JSON.parse response.body
        expect(json).to eql(
          'uuid' => reservation.uuid,
          'start_datetime' => reservation.start_datetime.iso8601(3),
          'end_datetime' => reservation.end_datetime.iso8601(3),
          'item' => { 'name' => item.name },
          'item_type' => { 'name' => item_type.name }
        )
      end
    end
    context 'with no available item' do
      before :each do
        expect_any_instance_of(ItemType)
          .to receive(:find_available)
          .with(default_start_time, default_end_time)
          .and_return nil
      end
      it 'has an unprocessable entity status' do
        submit
        expect(response).to have_http_status :unprocessable_entity
      end
      it 'has an empty response body' do
        submit
        expect(response.body).to be_empty
      end
    end
    context 'when passed an unknown item_type' do
      it 'has a not_found status' do
        submit_invalid_item_type_name
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'reservation found' do
      let(:reservation) { create :reservation, creator: service }
      let(:submit) { delete :destroy, id: reservation.uuid }
      context 'as creator of reservation' do
        let(:service) { authenticate! }
        it 'has on OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'deletes the reservation' do
          submit
          expect(Reservation.count).to be 0
        end
      end
      context 'as an unrelated service' do
        let(:service) { create :service }
        before(:each) { authenticate! }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'reservation not found' do
      let(:submit) { delete :destroy, id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let :submit do
      get :index, item_type: item_type.name,
                  start_time: default_start_time.iso8601,
                  end_time: default_end_time.iso8601
    end
    context 'item type found' do
      let(:item_type) { create :item_type }
      let(:item) { create :item, item_type: item_type }
      let!(:reservation) { create :reservation, item: item }
      context 'read access to item type' do
        before(:each) { authenticate_with_access_to :read, item_type }
        it 'includes the ISO 8601 start and end times of the reservation' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            [{ 'start_datetime' => reservation.start_datetime.iso8601(3),
               'end_datetime' => reservation.end_datetime.iso8601(3) }]
          )
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
      let(:item_type) { double name: 'Apples' }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #show' do
    context 'reservation found' do
      let(:reservation) { create :reservation, creator: service }
      let(:submit) { get :show, id: reservation.uuid }
      context 'as creator of reservation' do
        let(:service) { authenticate! }
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'responds with the found reservation' do
          submit
          json = JSON.parse response.body
          expect(json).to eql(
            'uuid' => reservation.uuid,
            'start_datetime' => reservation.start_datetime.iso8601(3),
            'end_datetime' => reservation.end_datetime.iso8601(3),
            'item' => { 'name' => reservation.item.name },
            'item_type' => { 'name' => reservation.item_type.name }
          )
        end
      end
      context 'as an unrelated service' do
        let(:service) { create :service }
        before(:each) { authenticate! }
        it 'has an unauthorized status' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end
    context 'reservation not found' do
      let(:submit) { get :show, id: 0 }
      before(:each) { authenticate! }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PUT #update' do
    let :reservation do
      create :reservation,
             start_datetime: 1.week.ago.to_datetime,
             end_datetime: Time.zone.today.to_datetime,
             creator: service
    end
    let(:new_start_time) { default_end_time }
    let(:new_end_time) { default_start_time }
    let :changes do
      { start_time: new_start_time.iso8601,
        end_time: new_end_time.iso8601 }
    end
    let(:submit) { put :update, id: reservation.uuid, reservation: changes }
    context 'as creator of reservation' do
      let(:service) { authenticate! }
      context 'change applied successfully' do
        before :each do
          expect_any_instance_of(Reservation)
            .to receive(:update)
            .with(start_datetime: new_start_time,
                  end_datetime: new_end_time)
            .and_return true
        end
        it 'calls #update on the reservation with the interpolated times' do
          submit
        end
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'responds with the new attributes' do
          submit
          json = JSON.parse response.body
          reservation.reload
          expect(json).to eql(
            'uuid' => reservation.uuid,
            'start_datetime' => reservation.start_datetime.iso8601(3),
            'end_datetime' => reservation.end_datetime.iso8601(3),
            'item' => { 'name' => reservation.item.name },
            'item_type' => { 'name' => reservation.item_type.name }
          )
        end
      end
      context 'change not applied successfully' do
        let(:error_messages) { ['Start time must be before end time'] }
        before :each do
          expect_any_instance_of(Reservation)
            .to receive(:update)
            .with(start_datetime: new_start_time,
                  end_datetime: new_end_time)
            .and_call_original
        end
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'responds with an object containing the reservation errors' do
          submit
          json = JSON.parse response.body
          expect(json).to eql 'errors' => error_messages
        end
      end
    end
    context 'as unrelated service' do
      let(:service) { create :service }
      before(:each) { authenticate! }
      it 'has an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'POST #update_item' do
    let(:item_type) { create :item_type, allowed_keys: [:mileage] }
    let(:item) { create :item, item_type: item_type }
    let(:reservation) { create :reservation, item: item, creator: service }
    let(:changes) { { color: 'orange' } }
    let(:submit) { post :update_item, id: reservation.uuid, data: changes }
    context 'as creator of reservation' do
      let(:service) { authenticate! }
      context 'change applied successfully' do
        before :each do
          expect_any_instance_of(Item)
            .to receive(:update)
            .with(data: changes.stringify_keys)
            .and_return true
        end
        it 'calls #update on the item with the changes' do
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
        let(:error_messages) { ['Disallowed key: color'] }
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'responds with an object containing the reservation errors' do
          submit
          json = JSON.parse response.body
          expect(json).to eql 'errors' => error_messages
        end
      end
    end
    context 'as an unrelated service' do
      let(:service) { create :service }
      before(:each) { authenticate! }
      it 'has an unauthorized status' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
