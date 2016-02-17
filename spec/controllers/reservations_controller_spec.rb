require 'rails_helper'

describe ReservationsController do
  describe 'POST #create' do
    let(:item_type) { create :item_type }
    let(:item) { create :item, item_type: item_type }
    let(:start_datetime) { Date.yesterday.to_datetime }
    let(:end_datetime) { Date.tomorrow.to_datetime }
    let :submit do
      post :create,
           item_type: item_type.name,
           start_time: start_datetime.iso8601,
           end_time: end_datetime.iso8601
    end
    context 'with available item' do
      let(:reservation) { create :reservation, item: item }
      before :each do
        expect_any_instance_of(ItemType)
          .to receive(:find_available)
          .with(start_datetime, end_datetime)
          .and_return item
        expect_any_instance_of(Item)
          .to receive(:reserve!)
          .with(start_datetime, end_datetime)
          .and_return reservation
      end
      it 'calls #reserve! on the item' do
        submit
      end
      it 'has an OK status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'responds with an object containing the reservation ID' do
        submit
        json = JSON.parse response.body
        expect(json).to eql 'id' => reservation.id
      end
    end
    context 'with no available item' do
      before :each do
        expect_any_instance_of(ItemType)
          .to receive(:find_available)
          .with(start_datetime, end_datetime)
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
    let(:item) { create :item, allowed_keys: [:mileage] }
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
      let(:error_messages) { [ 'Disallowed key: color' ] }
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
