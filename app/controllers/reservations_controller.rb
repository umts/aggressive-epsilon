class ReservationsController < ApplicationController
  before_action :find_reservation, only: %i(destroy show update update_item)

  def create
    item_type = ItemType.find_by name: params.require(:item_type)
    start_datetime = DateTime.iso8601 params.require(:start_time)
    end_datetime = DateTime.iso8601 params.require(:end_time)
    item = item_type.find_available start_datetime, end_datetime
    if item.present?
      reservation = item.reserve! start_datetime, end_datetime
      render json: reservation, only: :id
    else render nothing: true, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation.destroy
    render nothing: true
  end

  def index
    item_type = ItemType.find_by name: params.require(:item_type)
    if item_type.present?
      start_datetime = DateTime.iso8601 params.require(:start_time)
      end_datetime = DateTime.iso8601 params.require(:end_time)
      reservations = item_type.reservations.during start_datetime, end_datetime
      reservations = reservations.map do |reservation|
        { start_time: reservation.start_datetime.iso8601,
          end_time: reservation.end_datetime.iso8601 }
      end
      render json: reservations
    else render nothing: true, status: :not_found
    end
  end

  def show
    render json: { start_time: @reservation.start_datetime.iso8601,
                   end_time: @reservation.end_datetime.iso8601,
                   item_type: @reservation.item_type.name }
  end

  def update
    params.require(:reservation).permit(:start_time, :end_time)
    if @reservation.update datetime_interpolated_changes
      render nothing: true
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

  def find_reservation
    @reservation = Reservation.find_by id: params.require(:id)
    render nothing: true, status: :not_found unless @reservation.present?
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
