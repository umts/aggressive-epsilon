require 'rails_helper'

describe Item do
  
  describe 'creation' do
    let(:item) {create :item}
    it 'generates a uuid' do
      expect(item.uuid).not_to be nil
    end
  end
  
  describe 'available_between' do
    let(:call) { Item.available_between default_start_time, default_end_time }
    let!(:item) { create :item }
    let!(:unreservable_item) { create :item, reservable: false }
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
    it 'excludes items which are not reservable' do
      expect(call).not_to include unreservable_item
    end
  end

  describe 'reserve!' do
    let(:item) { create :item }
    let(:creator) { create :service }
    let :call do
      item.reserve! from: default_start_time,
                    to: default_end_time,
                    creator: creator
    end
    it 'creates a reservation for the item' do
      expect { call }.to change { Reservation.count }.by 1
      reservation = Reservation.last
      expect(reservation.item).to eql item
    end
  end
end
