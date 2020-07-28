# frozen_string_literal: true
require "active_support/concern"

module VerificationsDefaultActionAuthorizerExtend
  extend ActiveSupport::Concern

  included do

    def initialize(authorization, options, component, resource, action)
      @authorization = authorization
      @options = options.deep_dup || {} # options hash is cloned to allow changes applied to it without risks
      @component = resource.try(:component) || component
      @resource = resource
      @action = action
    end

    protected

    attr_reader :authorization, :options, :component, :resource, :action

  end
end

Decidim::Verifications::DefaultActionAuthorizer.send(:include, VerificationsDefaultActionAuthorizerExtend)
