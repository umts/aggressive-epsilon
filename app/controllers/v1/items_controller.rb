module V1
  class ItemsController < ApplicationController
    before_action :find_item, only: %i(destroy show update)

    def create
      item_type = ItemType.find_by id: params.require(:item_type_id)
      deny_access! and return unless @service.can_write_to? item_type
      item = Item.new params.permit(:name, :item_type_id, :reservable, data: {})
      if item.save
        render json: item, except: %i(created_at updated_at)
      else render json: { errors: item.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    def destroy
      deny_access! and return unless @service.can_write_to? @item.item_type
      @item.destroy
      render nothing: true
    end

    def index
      item_type = ItemType.find_by id: params.require(:item_type_id)
      deny_access! and return unless @service.can_read? item_type
      render json: item_type.items.order(:name),
             except: %i(created_at updated_at)
    end

    def show
      deny_access! and return unless @service.can_read? @item.item_type
      render json: @item, except: [:created_at, :updated_at]
    end

    def update
      deny_access! and return unless @service.can_write_to? @item.item_type
      metadata_keys = params[:item][:data].try(:keys)
      changes = params.require(:item).permit :name,
                                             :item_type_id,
                                             :reservable,
                                             data: metadata_keys
      if moving_item_to_unauthorized_type?
        deny_access! 'You do not have write access to the new item type'
        return
      end
      if @item.update changes
        render json: @item, except: %i(created_at updated_at)
      else render json: { errors: @item.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    private

    def moving_item_to_unauthorized_type?
      if params[:item].key? :item_type_id
        new_item_type = ItemType.find_by id: params[:item][:item_type_id]
        return true unless @service.can_write_to? new_item_type
      end
    end

    def find_item
      @item = Item.find_by id: params.require(:id)
      render nothing: true, status: :not_found unless @item.present?
    end
  end
end
