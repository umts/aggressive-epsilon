class ReservationsController < ApplicationController
  before_action :find_reservation, only: %i(destroy show update update_item)

  def create
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
