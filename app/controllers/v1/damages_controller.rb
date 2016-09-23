module V1
  class DamagesController < ApplicationController
    before_action :get_damage, only: %i(destroy show)

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
      damage_issued_reservation = Reservation.find_by uuid: params.require(:damage_issued_reservation_uuid)
      damage_fixed_reservation = Reservation.find_by uuid: params.require(:damage_fixed_reservation_uuid)
      if  !damage_issued_reservation.nil? && !damage_fixed_reservation.nil?
        issued_item = damage_issued_reservation.item
        fixed_item = damage_fixed_reservation.item
        if issued_item.uuid == fixed_item.uuid
            damage = issued_item.report_damage rental_reservation: damage_issued_reservation.uuid,
                                               repair_reservation: damage_fixed_reservation.uuid,
                                               damage_type: damage_type,
                                               creator: @service
            render json: damage and return if damage.valid?
        end
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

    def get_damage
      @damage = Damage.find_by uuid: params.require(:id)
      unless @damage.present?
        render nothing: true, status: :not_found and return
      end
    end
  end
end
