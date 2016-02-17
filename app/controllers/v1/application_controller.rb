module V1
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    before_action :destroy_session

    private

    def destroy_session
      request.session_options[:skip] = true
    end
  end
end
