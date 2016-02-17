require 'rails_helper'

describe Reservation do
  describe 'during' do
    let(:start_datetime) { Date.yesterday.to_datetime }
    let(:end_datetime) { Date.tomorrow.to_datetime }
    let(:call) { Reservation.during start_datetime, end_datetime }
    it 'includes a reservation starting in the given range' do
      reservation = create :reservation,
                           start_datetime: start_datetime + 1.day,
                           end_datetime: end_datetime + 1.day
      expect(call).to include reservation
    end
    it 'includes a reservation ending in the given range' do
      reservation = create :reservation,
                           start_datetime: start_datetime - 1.day,
                           end_datetime: end_datetime - 1.day
      expect(call).to include reservation
    end
    it 'includes a reservation spanning the given range' do
      reservation = create :reservation,
                           start_datetime: start_datetime - 1.day,
                           end_datetime: end_datetime + 1.day
      expect(call).to include reservation
    end
    it 'excludes a reservation not during the range' do
      reservation = create :reservation,
                           start_datetime: 1.week.ago.to_datetime,
                           end_datetime: 6.days.ago.to_datetime
      expect(call).not_to include reservation
    end
  end
end
