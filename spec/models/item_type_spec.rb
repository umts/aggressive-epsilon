require 'rails_helper'

describe ItemType do
  describe 'creation' do
    it 'converts allowed keys to symbols' do
      item_type = build :item_type, allowed_keys: %w(color)
      item_type.save
      expect(item_type.allowed_keys).to eql %i(color)
    end
  end

  describe 'find_available' do
    let(:item_type) { create :item_type }
    let(:call) { item_type.find_available default_start_time, default_end_time }
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
