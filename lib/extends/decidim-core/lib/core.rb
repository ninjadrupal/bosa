# frozen_string_literal: true
require "active_support/concern"

module DecidimCoreExtend
  extend ActiveSupport::Concern

  included do

    # Exposes a configuration option: The application translatable locale.
    config_accessor :translatable_locales do
      %w(en de fr es pt it nl pl ru)
    end

  end
end

Decidim.send(:include, DecidimCoreExtend)
