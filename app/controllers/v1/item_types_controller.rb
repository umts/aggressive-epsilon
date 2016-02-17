module V1
  class ItemTypesController < ApplicationController
    def index
      render json: ItemType.order(:name), only: [:name, :allowed_keys],
             include: { items: { only: :name } }
    end
  end
end
