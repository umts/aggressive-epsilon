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
  end

  def update_item
  end

  private

  def find_reservation
    @reservation = Reservation.find params.require(:id)
  end
end
