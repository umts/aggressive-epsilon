require 'rails_helper'

describe Service do
  describe 'can_read?' do
    let(:service) { create :service }
    let(:item_type) { create :item_type }
    context 'no permission from service to item type' do
      it 'returns false' do
        expect(service).not_to be_able_to_read item_type
      end
    end
    context 'normal permission from service to item type' do
      before :each do
        create :permission, service: service, item_type: item_type
      end
      it 'returns true' do
        expect(service).to be_able_to_read item_type
      end
    end
    context 'write permission from service to item type' do
      before :each do
        create :permission, service: service, item_type: item_type,
                            write: true
      end
      it 'returns true' do
        expect(service).to be_able_to_read item_type
      end
    end
  end

  describe 'can_write?' do
    let(:service) { create :service }
    let(:item_type) { create :item_type }
    context 'no permission from service to item type' do
      it 'returns false' do
        expect(service).not_to be_able_to_write_to item_type
      end
    end
    context 'normal permission from service to item type' do
      before :each do
        create :permission, service: service, item_type: item_type
      end
      it 'returns true' do
        expect(service).not_to be_able_to_write_to item_type
      end
    end
    context 'write permission from service to item type' do
      before :each do
        create :permission, service: service, item_type: item_type,
                            write: true
      end
      it 'returns true' do
        expect(service).to be_able_to_write_to item_type
      end
    end
  end

  describe 'readable_item_types' do
    let(:service) { create :service }
    let(:item_type) { create :item_type }
    it 'returns an item type with an existing permission with the service' do
      create :permission, service: service, item_type: item_type
      expect(service.readable_item_types).to include item_type
    end
    it 'does not return an item type without with an existing permission' do
      expect(service.readable_item_types).not_to include item_type
    end
  end
end
