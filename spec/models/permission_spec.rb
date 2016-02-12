require 'rails_helper'

describe Permission do
  describe 'basic creation' do
    it 'works' do
      expect { create :permission }.not_to raise_error
    end
  end
end
