require 'rails_helper'

RSpec.describe Damage, type: :model do
  describe 'creation' do
    let(:damage) {create :damage}
    it 'create an uuid' do
      expect(damage.uuid).not_to be nil
    end
  end
end
