require 'rails_helper'

describe ItemTypesController do
  describe 'GET #index' do
    let(:submit) { get :index }
    it 'renders all item types' do
      apples = create :item_type, name: 'Apples', allowed_keys: [:flavor]
      create :item, item_type: apples, name: 'Apple 1'
      create :item, item_type: apples, name: 'Apple 2'
      submit
      json = JSON.parse response.body
      expect(json).to eql [{ 'name' => 'Apples',
                             'allowed_keys' => ['flavor'],
                             'items' => [{ 'name' => 'Apple 1' },
                                         { 'name' => 'Apple 2' }] }]
    end
  end
end
