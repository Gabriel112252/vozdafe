module Api
  module V1
    class DevotionalsController < ApplicationController
      def create
        unless params[:message].is_a?(String)
          return render json: { error: "Informe uma mensagem de texto." }, status: :unprocessable_entity
        end
        render json: DevotionalGenerator.call(params[:message]), status: :ok
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
