require 'rails_helper'

describe Service do
  describe 'basic creation' do
    it 'works' do
      expect { create :service }.not_to raise_error
    end
  end
end
