# frozen_string_literal: true
require "active_support/concern"

module VerificationsAuthorizationsControllerExtend
  extend ActiveSupport::Concern

  included do

    helper_method :handler, :unauthorized_methods, :disabled_methods, :authorization_anti_affinity

    helper MetadataHelper

    protected

    def unauthorized_methods
      @unauthorized_methods ||= available_verification_workflows.reject do |handler|
        (active_authorization_methods + authorization_anti_affinity).include?(handler.key)
      end
    end

    def disabled_methods
      @disabled_methods ||= available_verification_workflows.select do |handler|
        authorization_anti_affinity.include?(handler.key)
      end
    end

    def authorization_anti_affinity
      @authorization_anti_affinity ||= active_authorization_methods.map do |handler|
        Decidim::Verifications.find_workflow_manifest(handler).anti_affinity
      end.flatten.compact
    end


  end
end

Decidim::Verifications::AuthorizationsController.send(:include, VerificationsAuthorizationsControllerExtend)
