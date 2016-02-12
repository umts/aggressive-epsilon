class ItemTypesController < ApplicationController
  def index
    render json: ItemType.order(:name), only: :name,
           include: { items: { only: :name } }
    nil
  end
end
