require 'rails_helper'

describe ItemType do
  describe 'basic creation' do
    it 'works' do
      expect { create :item_type }.not_to raise_error
    end
  end
end
