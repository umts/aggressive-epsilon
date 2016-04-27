module V1
  class ReservationsController < ApplicationController
    before_action :find_reservation, only: %i(destroy show update update_item)
    before_action :find_item_type, only: :index

    def create
      item_type = ItemType.find_by name: params.require(:item_type)
      render nothing: true, status: :not_found and return if item_type.nil?
      start_time = DateTime.iso8601 params.require(:start_time)
      end_time = DateTime.iso8601 params.require(:end_time)
      item = item_type.find_available start_time, end_time
      if item.present?
        reservation = item.reserve! from: start_time,
                                    to: end_time,
                                    creator: @service
        render json: reservation
      else render nothing: true, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy
      render nothing: true
    end

    def index
      start_datetime = DateTime.iso8601 params.require(:start_time)
      end_datetime = DateTime.iso8601 params.require(:end_time)
      reservations = @item_type.reservations
                               .during start_datetime, end_datetime
      reservations = reservations.map do |reservation|
        { start_time: reservation.start_datetime.iso8601,
          end_time: reservation.end_datetime.iso8601 }
      end
      render json: reservations
    end

    def show
      render json: @reservation
    end

    def update
      params.require(:reservation).permit(:start_time, :end_time)
      if @reservation.update datetime_interpolated_changes
        render json: @reservation
      else render json: { errors: @reservation.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    def update_item
      if @reservation.item.update data: params.require(:data)
        render nothing: true
      else render json: { errors: @reservation.item.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    private

    def find_item_type
      @item_type = ItemType.find_by name: params.require(:item_type)
      unless @item_type.present?
        render nothing: true, status: :not_found and return
      end
      deny_access! and return unless @service.can_read? @item_type
    end

    def find_reservation
      @reservation = Reservation.find_by uuid: params.require(:id)
      unless @reservation.present?
        render nothing: true, status: :not_found and return
      end
      deny_access! and return unless @service.can_edit? @reservation
    end

    def datetime_interpolated_changes
      changes = {}
      reservation = params[:reservation]
      if reservation[:start_time].present?
        changes[:start_datetime] = DateTime.iso8601 reservation[:start_time]
      end
      if reservation[:end_time].present?
        changes[:end_datetime] = DateTime.iso8601 reservation[:end_time]
      end
      changes
    end
  end
end
