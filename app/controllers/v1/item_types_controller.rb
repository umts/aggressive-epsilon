module V1
  class ItemTypesController < ApplicationController
    before_action :find_item_type, only: %i(destroy show update)

    def index
      render json: ItemType.order(:name), except: [:created_at, :updated_at],
             include: { items: { only: :name } }
    end

    def show
      render json: @item_type, except: [:created_at, :updated_at],
             include: { items: { only: [:id, :name] } }
    end

    private

    def find_item_type
      @item_type = ItemType.find_by id: params.require(:id)
      render nothing: true, status: :not_found unless @item_type.present?
    end
  end
end
