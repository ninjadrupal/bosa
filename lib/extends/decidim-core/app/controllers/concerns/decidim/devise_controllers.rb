# frozen_string_literal: true

require "active_support/concern"

module DeviseControllersExtend
  extend ActiveSupport::Concern

  included do
    # Weird bug for sign_in/sign_out actions, it is missing redirect_url helper method
    include Decidim::SafeRedirect
  end
end

Decidim::DeviseControllers.send(:include, DeviseControllersExtend)
