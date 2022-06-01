# frozen_string_literal: true

module Decidim
  module Api
    class TranslationController < Decidim::Api::ApplicationController
      before_action :verify_authenticity_token

      def translate
        if params[:original].present? && params[:target].present?
          auth_key = current_organization.try(:deepl_api_key) || Rails.application.secrets.try(:deepl_api_key)

          uri = URI.parse("https://api.deepl.com/v2/translate")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = Net::HTTP::Post.new(uri)
          request.set_form_data(target_lang: params[:target],
                                text: params[:original],
                                auth_key: auth_key,
                                tag_handling: "xml")

          response = http.request(request)
          result = response.body.empty? ? empty_response : JSON.parse(response.body)

          render json: result
        else
          render json: { status: :params_missing }
        end
      end

      private

      def empty_response
        { status: :empty_response }
      end
    end
  end
end
