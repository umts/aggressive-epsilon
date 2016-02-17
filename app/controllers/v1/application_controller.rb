module V1
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :destroy_session
    before_action :check_api_token

    private

    def check_api_token
    end

    def destroy_session
      request.session_options[:skip] = true
    end
  end
end
