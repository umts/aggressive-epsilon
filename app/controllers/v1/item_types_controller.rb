module V1
  class ItemTypesController < ApplicationController
    before_action :find_item_type, only: %i(destroy show update)

    def destroy
      @item_type.destroy
      render nothing: true
    end

    def index
      render json: ItemType.order(:name), except: [:created_at, :updated_at],
             include: { items: { only: :name } }
    end

    def show
      render json: @item_type, except: [:created_at, :updated_at],
             include: { items: { only: [:id, :name] } }
    end

    def update
      changes = params.require(:item_type).permit :name
      if @item_type.update changes then render nothing: true
      else render json: { errors: @item_type.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    private

    def find_item_type
      @item_type = ItemType.find_by id: params.require(:id)
      render nothing: true, status: :not_found unless @item_type.present?
    end
  end
end
