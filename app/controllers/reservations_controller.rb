class ReservationsController < ApplicationController
  before_action :find_reservation, only: %i(destroy show update update_item)

  def create
    item_type = ItemType.find_by name: params.require(:item_type)
    start_datetime = DateTime.iso8601 params.require(:start_time)
    end_datetime = DateTime.iso8601 params.require(:end_time)
    item = item_type.find_available start_datetime, end_datetime
    if item
      reservation = item.reserve! start_datetime, end_datetime
      render json: reservation, only: :id
    else render nothing: true, status: :unprocessable_entity
    end
  end

  def destroy
  end

  def index
  end

  def show
  end

  def update
    params.require(:reservation).permit(:start_time, :end_time)
    if @reservation.update interpolated_changes
      render nothing: true, status: :ok
    else render json: { errors: @reservation.errors.full_messages },
                status: :unprocessable_entity
    end
  end

  def update_item
    if @reservation.item.update params.require(:data)
      render nothing: true, status: :ok
    else render json: { errors: @reservation.item.errors.full_messages },
                status: :unprocessable_entity
    end
  end

  private

  def find_reservation
    @reservation = Reservation.find params.require(:id)
  end

  def interpolated_changes
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
