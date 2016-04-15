require 'rails_helper'
include ReservationHelper

describe Reservation do
  describe 'during' do
    let(:call) { Reservation.during default_start_time, default_end_time }
    it 'includes a reservation starting in the given range' do
      reservation = reservation_with_times :starting_in_default_range
      expect(call).to include reservation
    end
    it 'includes a reservation ending in the given range' do
      reservation = reservation_with_times :ending_in_default_range
      expect(call).to include reservation
    end
    it 'includes a reservation spanning the given range' do
      reservation = reservation_with_times :spanning_default_range
      expect(call).to include reservation
    end
    it 'excludes a reservation not during the range' do
      reservation = reservation_with_times :not_during_default_range
      expect(call).not_to include reservation
    end
  end
end
