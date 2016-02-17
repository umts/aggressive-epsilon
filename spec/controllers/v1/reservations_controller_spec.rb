require 'rails_helper'

describe V1::ReservationsController do
  before(:each) { authenticate! }
  describe 'POST #create' do
    let(:item_type) { create :item_type }
    let(:item) { create :item, item_type: item_type }
    let :submit do
      post :create,
           item_type: item_type.name,
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
          .with(default_start_time, default_end_time)
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
        expect(response.body).to eql reservation.to_json
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
  end

  describe 'DELETE #destroy' do
    context 'reservation found' do
      let(:reservation) { create :reservation }
      let(:submit) { delete :destroy, id: reservation.id }
      it 'deletes the reservation' do
        submit
        expect(Reservation.count).to be 0
      end
      it 'has on OK status' do
        submit
        expect(response).to have_http_status :ok
      end
    end
    context 'reservation not found' do
      let(:submit) { delete :destroy, id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #show' do
    context 'reservation found' do
      let(:reservation) { create :reservation }
      let(:submit) { get :show, id: reservation.id }
      it 'has an OK status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'responds with the found reservation' do
        submit
        expect(response.body).to eql reservation.to_json
      end
    end
    context 'reservation not found' do
      let(:submit) { get :show, id: 0 }
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
      it 'includes the ISO 8601 start and end times of the reservation' do
        submit
        json = JSON.parse response.body
        expect(json).to include
        { 'start_time' => reservation.start_datetime.iso8601,
          'end_time' => reservation.end_datetime.iso8601 }
      end
    end
    context 'item type not found' do
      let(:item_type) { double name: 'Apples' }
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
             end_datetime: Time.zone.today.to_datetime
    end
    let(:new_start_time) { Time.zone.tomorrow.to_datetime }
    let(:changes) { { start_time: new_start_time.iso8601 } }
    let(:submit) { put :update, id: reservation.id, reservation: changes }
    context 'change applied successfully' do
      before :each do
        expect_any_instance_of(Reservation)
          .to receive(:update)
          .with(start_datetime: new_start_time)
          .and_return true
      end
      it 'calls #update on the reservation with the interpolated times' do
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
      let(:error_messages) { ['Start time must be before end time'] }
      before :each do
        expect_any_instance_of(Reservation)
          .to receive(:update)
          .with(start_datetime: new_start_time)
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

  describe 'POST #update_item' do
    let(:item_type) { create :item_type, allowed_keys: [:mileage] }
    let(:item) { create :item, item_type: item_type }
    let(:reservation) { create :reservation, item: item }
    let(:changes) { { color: 'orange' } }
    let(:submit) { post :update_item, id: reservation.id, data: changes }
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
end
