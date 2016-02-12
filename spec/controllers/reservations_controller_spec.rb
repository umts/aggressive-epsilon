require 'rails_helper'

describe ReservationsController do
  describe 'POST #create' do
    let(:submit) { post :create }
    it 'is routable' do
      expect { submit }.not_to raise_error
    end
    it 'renders empty JSON' do
      submit
      expect(JSON.parse response.body).to eql Hash.new
    end
  end

  describe 'DELETE #destroy' do
    let(:reservation) { create :reservation }
    let(:submit) { delete :destroy, id: reservation.id }
    it 'is routable' do
      expect { submit }.not_to raise_error
    end
    it 'renders empty JSON' do
      submit
      expect(JSON.parse response.body).to eql Hash.new
    end
  end
end
