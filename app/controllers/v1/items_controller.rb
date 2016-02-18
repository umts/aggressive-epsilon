module V1
  class ItemsController < ApplicationController
    before_action :find_item, only: %i(destroy show update)

    def create
      item = Item.new params.permit(:name, :item_type_id, data: {})
      if item.save
        render json: item, except: %i(created_at updated_at)
      else render json: { errors: item.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy
      render nothing: true
    end

    def index
      item_type = ItemType.find_by id: params.require(:item_type_id)
      render json: item_type.items.order(:name),
             except: %i(created_at updated_at)
    end

    def show
      render json: @item, except: [:created_at, :updated_at]
    end

    def update
      metadata_keys = params[:item][:data].try(:keys)
      changes = params.require(:item).permit :name,
                                             :item_type_id,
                                             data: metadata_keys
      if @item.update changes then render nothing: true
      else render json: { errors: @item.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    private

    def find_item
      @item = Item.find_by id: params.require(:id)
      render nothing: true, status: :not_found unless @item.present?
    end
  end
end
