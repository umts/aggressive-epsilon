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
      end
      it 'calls #reserve! on the item' do
        expect_any_instance_of(Item)
          .to receive(:reserve!)
          .with(start_datetime, end_datetime)
          .and_return reservation
        submit
      end
    end
    context 'with unavailable item' do
    end
  end
end
