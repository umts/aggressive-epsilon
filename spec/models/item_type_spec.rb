require 'rails_helper'

describe ItemType do
  describe 'find_available' do
    let(:start_datetime) { Date.yesterday.to_datetime }
    let(:end_datetime) { Date.tomorrow.to_datetime }
    let(:item_type) { create :item_type }
    let(:call) { item_type.find_available start_datetime, end_datetime }
    it 'finds an item available in the time range' do
      item = create :item, item_type: item_type
      expect(call).to eql item
    end
    it 'does not find available items in another item type' do
      other_item = create :item
      expect(call).not_to eql other_item and expect(call).to be nil
    end
  end
end
