class ItemTypesController < ApplicationController
  def index
    render json: ItemType.order(:name), only: :name,
           include: { items: { only: :name } } and return
  end
end
