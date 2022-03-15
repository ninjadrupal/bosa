# frozen_string_literal: true

require "active_support/concern"

module ScopesHelperExtend
  extend ActiveSupport::Concern

  included do

    # def current_participatory_space
    #   # This is a stub
    #   # Used to fix failing test: /spec/decidim-assemblies/spec/helpers/decidim/scopes_helper_spec.rb
    #   # TODO: double check after upgrade to 0.24.3
    #   raise NotImplementedError
    # end

  end
end

Decidim::ScopesHelper.send(:include, ScopesHelperExtend)
