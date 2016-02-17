require 'rails_helper'

describe Item do
  describe 'available_between' do
    let(:call) { Item.available_between default_start_time, default_end_time }
    let!(:item) { create :item }
    it 'calls Reservation.during' do
      expect(Reservation)
        .to receive(:during)
        .with(default_start_time, default_end_time)
        .and_return Reservation.none
      call
    end
    it 'includes an item with no reservations' do
      expect(call).to include item
    end
  end

  describe 'reserve!' do
    let(:item) { create :item }
    let(:call) { item.reserve! default_start_time, default_end_time }
    it 'creates a reservation for the item' do
      expect { call }.to change { Reservation.count }.by 1
      reservation = Reservation.last
      expect(reservation.item).to eql item
    end
  end
end
