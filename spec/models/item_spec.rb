require 'rails_helper'

describe Item do
  describe 'basic creation' do
    it 'works' do
      expect { create :item }.not_to raise_error
    end
  end
end
