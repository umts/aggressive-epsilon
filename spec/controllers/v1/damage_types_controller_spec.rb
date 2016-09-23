require 'rails_helper'

describe V1::DamageTypesController do
  let!(:creator) { authenticate! }
  describe 'POST #create' do
    let!(:name) { 'TEST DAMAGE TYPE' }
    let(:submit) { post :create, name: name }

    context 'damage type created successfully' do
      let(:damage_type) { create :damage_type, creator_id: creator.id }
      before :each do
        expect(DamageType)
          .to receive(:new)
          .with(name: name, creator_id: creator.id)
          .and_return damage_type
      end
      it 'has an ok status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'return the damage type' do
        submit
        expect(JSON.parse(response.body)).to eql(
          'uuid' => damage_type.uuid,
          'name' => damage_type.name,
          'damages' => [])
      end
    end

    context 'error when creating damage type' do
      let(:name) { ' ' }
      let(:error_messages) { ["Name can't be blank"] }
      it 'has an unprocessable status' do
        submit
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns the errors of the item type' do
        submit
        expect(JSON.parse(response.body)).to eql 'errors' => error_messages
      end
    end
  end

  describe 'POST #destroy' do
    let(:submit) { delete :destroy, id: damage_type.uuid }
    context 'damage type found' do
      let(:damage_type) { create :damage_type }
      it 'has an ok status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'delete any damages that belongs to the damage type' do
        create :damage, damage_type: damage_type
        expect(Damage.count).to be 1
        submit
        expect(Damage.count).to be 0
      end
      it 'delete the damage type' do
        submit
        expect(DamageType.count).to be 0
      end
    end
    context 'damage type does not found' do
      let(:damage_type) { double uuid: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET #index' do
    let(:submit) { get :index }
    let(:damage_type) { create :damage_type }
    let!(:damage1) { create :damage, damage_type: damage_type }
    let!(:damage2) { create :damage, damage_type: damage_type }
    it 'render all damgage type' do
      submit
      expect(JSON.parse(response.body)).to eql(
        [{ 'uuid' => damage_type.uuid,
           'name' => damage_type.name,
           'damages' => [{ 'uuid' => damage1.uuid },
                         { 'uuid' => damage2.uuid }] }])
    end
  end

  describe 'GET #show' do
    let(:submit) { get :show, id: damage_type.uuid }
    context 'damage_type found' do
      let(:damage_type) { create :damage_type }
      let!(:damage) { create :damage, damage_type: damage_type }
      it 'has an ok status' do
        submit
        expect(response).to have_http_status :ok
      end
      it 'get the proper damage_type' do
        submit
        expect(JSON.parse(response.body)).to eql(
          'uuid' => damage_type.uuid,
          'name' => damage_type.name,
          'damages' => [{ 'uuid' => damage.uuid }])
      end
    end
    context 'damage_type not found' do
      let(:damage_type) { double uuid: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST #update' do
    let(:submit) { post :update, id: damage_type.uuid, damage_type: changes }
    let(:changes) { { name: 'New Damage Type Name' } }
    context 'damage type found' do
      let(:damage_type) { create :damage_type }
      context 'changes apply successfully' do
        it 'has a ok status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'calls #update on the item type with the changes' do
          expect_any_instance_of(DamageType)
            .to receive(:update)
            .with(changes.stringify_keys)
            .and_call_original
          submit
        end
        it 'responds with the new attributes' do
          submit
          expect(response.body).to eql(
            damage_type.reload.to_json(except:
                                     %i(created_at updated_at creator_id id))
          )
        end
      end
      context 'changes not apply' do
        let(:changes) { { name: nil } }
        let(:error_messages) { ["Name can't be blank"] }
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'responds with an object containing the item type errors' do
          submit
          expect(JSON.parse(response.body)).to eql 'errors' => error_messages
        end
      end
    end
    context 'damage type not found' do
      let(:damage_type) { double uuid: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
