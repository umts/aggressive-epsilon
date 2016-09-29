module V1
  class DamageTypesController < ApplicationController
    before_action :find_damage_type, only: %i(destroy show update)

    def index
      render json: DamageType.all,
             except: %i(created_at updated_at id creator_id),
             include: { damages: { only: :uuid } }
    end

    def create
      damage_type = DamageType.new params.permit(:name)
                    .merge creator_id: @service.id
      if damage_type.save
        render json: damage_type,
               except: %i(created_at updated_at creator_id id),
               include: :damages and return
      else
        render json: { errors: damage_type.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def update
      if @damage_type.update(params.require(:damage_type).permit(:name))
        render json: @damage_type,
               except: %i(created_at updated_at id creator_id) and return
      else render json: { errors: @damage_type.errors.full_messages },
                  status: :unprocessable_entity
      end
    end

    def show
      render json: @damage_type,
             except: %i(created_at updated_at id creator_id),
             include: { damages: { only: :uuid } }
    end

    def destroy
      @damage_type.destroy
      render nothing: true
    end

    private

    def find_damage_type
      @damage_type = DamageType.find_by uuid: params.require(:id)
      if @damage_type.nil?
        render nothing: true, status: :not_found
        return
      end
    end
  end
end
