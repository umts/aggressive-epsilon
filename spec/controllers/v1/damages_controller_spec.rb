require 'rails_helper'

describe V1::DamagesController do
  let!(:creator) { authenticate! }
  let(:damage_type) { create :damage_type }
  let(:item_type) { create :item_type }
  let(:item) { create :item, item_type: item_type }
  let(:rental_reservation) { create :reservation, item: item}
  let(:repair_reservation) { create :damage_reservation, item: item }

  describe 'POST #create' do
    let(:item2) { create :item, item_type: item_type }
    let(:rental_reservation2) { create :reservation, item: item2 }
    let(:submit) do
      post :create, damage_type: damage_type.name,
                    damage_issued_reservation_uuid: rental_reservation.uuid,
                    damage_fixed_reservation_uuid: repair_reservation.uuid
    end

    let(:submit_with_invalid_damage_type) do
      post :create, damage_type: 'some invalid damage type',
                    damage_issued_reservation_uuid: rental_reservation.uuid,
                    damage_fixed_reservation_uuid: repair_reservation.uuid
    end

    let(:submit_with_invalid_rental_reservation) do
      post :create, damage_type: damage_type.name,
                    damage_issued_reservation_uuid: 'some invalid rental reservation',
                    damage_fixed_reservation_uuid: repair_reservation.uuid
    end

    let(:submit_with_invalid_repair_reservation) do
      post :create, damage_type: damage_type.name,
                    damage_issued_reservation_uuid: rental_reservation.uuid,
                    damage_fixed_reservation_uuid: 'some invalid repair reservation'
    end

    let(:submit_with_reservations_items_different) do
      post :create, damage_type: damage_type.name,
                    damage_issued_reservation_uuid: rental_reservation2.uuid,
                    damage_fixed_reservation_uuid: repair_reservation.uuid
    end

    context 'with valid data' do
      let(:damage) { create :damage, item: item }

      before :each do
        expect_any_instance_of(Item)
        .to receive(:report_damage)
        .with(rental_reservation: rental_reservation.uuid,
              repair_reservation: repair_reservation.uuid,
              damage_type: damage_type,
              creator: creator)
        .and_return damage
      end

      it 'has an OK status' do
        submit
        expect(response).to have_http_status :ok
      end

      it 'responds with the created reservation' do
        submit
        expect(response.body).to eql damage.to_json
      end
    end

    context 'with invalid data' do
      it 'has a not_found status with invalid damage type' do
        submit_with_invalid_damage_type
        expect(response).to have_http_status :not_found
      end

      it 'has an unprocessable_entity with invalid rental reservation' do
        submit_with_invalid_rental_reservation
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'has an unprocessable_entity with invalid repair reservation' do
        submit_with_invalid_repair_reservation
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'has an unprocessable_entity with reservations with different items' do
        submit_with_reservations_items_different
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'POST #destroy' do
    let(:submit_destory) { delete :destroy, id: damage.uuid }

    context 'damage found' do
      let(:damage) { create :damage, item: item }
      it 'return ok status' do
        submit_destory
        expect(response).to have_http_status :ok
      end

      it 'delete the damage successfully' do
        submit_destory
        expect(Damage.count).to be 0
      end
    end

    context 'damage not found' do
      let(:submit) { delete :destroy, id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let(:submit) { get :index, item: item.name }
    let(:submit_invalid_item) { get :index, item: 'some invalid item'}
    let!(:damage) { create :damage, item: item }
    context 'item found' do
      it 'response contain the created item\'s damages' do
        submit
        expect(JSON.parse response.body).to include
        { "item_id" => damage.item.id,
          "damage_issued_reservation_uuid" => damage.damage_issued_reservation_uuid,
          "damage_fixed_reservation_uuid" => damage.damage_issued_reservation_uuid
        }
      end
    end

    context 'item not found' do
      it 'return an an not found status' do
        submit_invalid_item
        expect(response).to have_http_status :not_found
      end

      it 'return nothing' do
        submit_invalid_item
        expect(response.body).to be_empty
      end
    end
  end

  describe 'GET #show' do
    let!(:damage) { create :damage, item: item }
    let(:submit) { get :show, id: damage.uuid }
    let(:submit_invalid_damage) { get :show, id: 'some invalid damage'}

    context 'damage found' do
      it 'has ok status response' do
        submit
        expect(response).to have_http_status :ok
      end

      it 'response with the found damage' do
        submit
        expect(response.body).to eql damage.to_json
      end
    end

    context 'damage not found' do
      it 'has a not_found status' do
        submit_invalid_damage
        expect(response).to have_http_status :not_found
      end

      it 'response an empty body' do
        submit_invalid_damage
        expect(response.body).to be_empty
      end
    end
  end
end
