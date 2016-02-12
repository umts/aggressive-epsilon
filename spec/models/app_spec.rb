require 'rails_helper'

describe App do
  describe 'basic creation' do
    it 'works' do
      expect { create :app }.not_to raise_error
    end
  end
end
