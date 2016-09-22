require 'rails_helper'

RSpec.describe DamageType, type: :model do
  describe 'creation' do
    let(:damage_type) { create :damage_type }
    it 'generate an uuid' do
      expect(damage_type.uuid).not_to be nil
    end
  end
end
