require 'rails_helper'

describe Reservation do
  describe 'during' do
    let(:call) { Reservation.during default_start_time, default_end_time }
    it 'includes a reservation starting in the given range' do
      reservation = create :reservation, :starting_in_default_range
      expect(call).to include reservation
    end
    it 'includes a reservation ending in the given range' do
      reservation = create :reservation, :ending_in_default_range
      expect(call).to include reservation
    end
    it 'includes a reservation spanning the given range' do
      reservation = create :reservation, :spanning_default_range
      expect(call).to include reservation
    end
    it 'excludes a reservation not during the range' do
      reservation = create :reservation, :not_during_default_range
      expect(call).not_to include reservation
    end
  end
end
