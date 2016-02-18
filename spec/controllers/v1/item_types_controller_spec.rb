require 'rails_helper'

describe V1::ItemTypesController do
  describe 'GET #index' do
    before(:each) { authenticate! }
    let(:item_type) { create :item_type }
    let!(:item_1) { create :item, item_type: item_type }
    let!(:item_2) { create :item, item_type: item_type }
    let(:submit) { get :index }
    it 'renders all item types' do
      submit
      json = JSON.parse response.body
      expect(json).to eql(
        [{ 'id' => item_type.id,
           'name' => item_type.name,
           'allowed_keys' => item_type.allowed_keys.map(&:to_s),
           'items' => [{ 'name' => item_1.name },
                       { 'name' => item_2.name }] }])
    end
  end

  describe 'GET #show' do
    before(:each) { authenticate! }
    let(:submit) { get :show, id: item_type.id }
    context 'item type found' do
      let(:item_type) { create :item_type }
      let!(:item_1) { create :item, item_type: item_type }
      let!(:item_2) { create :item, item_type: item_type }
      it 'includes item type and item attributes' do
        submit
        json = JSON.parse response.body
        expect(json).to eql(
          'id' => item_type.id,
          'name' => item_type.name,
          'allowed_keys' => item_type.allowed_keys.map(&:to_s),
          'items' => [{ 'id' => item_1.id,
                        'name' => item_1.name },
                      { 'id' => item_2.id,
                        'name' => item_2.name }])
      end
    end
    context 'item type not found' do
      let(:item_type) { double id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
