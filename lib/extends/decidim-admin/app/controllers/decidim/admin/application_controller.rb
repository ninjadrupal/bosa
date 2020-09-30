# frozen_string_literal: true

require "active_support/concern"

module AdminApplicationControllerExtend
  extend ActiveSupport::Concern

  included do
    include Decidim::NeedsTosAccepted
  end
end

Decidim::Admin::ApplicationController.send(:include, AdminApplicationControllerExtend)
