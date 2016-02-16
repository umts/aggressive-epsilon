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
           start_datetime: start_datetime.iso8601,
           end_datetime: end_datetime.iso8601
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
end
