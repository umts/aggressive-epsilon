module V1
  class ItemTypesController < ApplicationController
    before_action :find_item_type, only: %i(destroy show update)

    def create
      deny_access! and return unless @service.can_write_to? # any
      item_type = ItemType.new params.permit(:name, allowed_keys: [])
                  .merge creator_id: @service.id
      if item_type.save
        render json: item_type, except: %i(created_at updated_at),
               include: :items # there won't be any
      else render json: { errors: item_type.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    def destroy
      deny_access! and return unless @service.can_write_to? @item_type
      @item_type.destroy
      render nothing: true
    end

    def index
      render json: @service.readable_item_types,
             except: %i(created_at updated_at),
             include: { items: { only: :name } }
    end

    def show
      deny_access! and return unless @service.can_read? @item_type
      render json: @item_type, except: %i(created_at updated_at),
             include: { items: { only: [:id, :name] } }
    end

    def update
      deny_access! and return unless @service.can_write_to? @item_type
      changes = params.require(:item_type).permit :allowed_keys, :name
      if @item_type.update changes
        render json: @item_type, except: %i(created_at updated_at)
      else render json: { errors: @item_type.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    private

    def find_item_type
      @item_type = ItemType.find_by id: params.require(:id)
      render nothing: true, status: :not_found and return if @item_type.blank?
    end
  end
end
