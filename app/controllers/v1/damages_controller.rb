module V1
  class DamagesController < ApplicationController
    before_action :find_damage, only: %i(destroy show)

    def index
      item = Item.find_by name: params.require(:item)
      if item.nil?
        render nothing: true, status: :not_found and return if item.nil?
      end
      render json: item.damages
    end

    def create
      damage_type = DamageType.find_by name: params.require(:damage_type)
      render nothing: true, status: :not_found and return if damage_type.nil?
      rental_reservation = Reservation.find_by(uuid: params.require(:rental_uuid))
      repair_reservation = Reservation.find_by(uuid: params.require(:repair_uuid))
      rental_item = rental_reservation.try(:item)
      repair_item = repair_reservation.try(:item)
      if rental_item.try(:uuid) == repair_item.try(:uuid)
        damage = rental_item.report_damage rental_reservation: rental_reservation.uuid,
                                           repair_reservation: repair_reservation.uuid,
                                           damage_type: damage_type,
                                           creator: @service
        render json: damage and return if damage.valid?
      end
      render nothing: true, status: :unprocessable_entity
    end

    def destroy
      @damage.destroy
      render nothing: true
    end

    def show
      render json: @damage
    end

    private

    def find_damage
      @damage = Damage.find_by uuid: params.require(:id)
      unless @damage.present?
        render nothing: true, status: :not_found and return
      end
    end
  end
end
