require 'rails_helper'

describe Reservation do
  describe 'basic creation' do
    it 'works' do
      expect { create :reservation }.not_to raise_error
    end
  end
end
