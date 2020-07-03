# frozen_string_literal: true
require "active_support/concern"

module ViewModelExtend
  extend ActiveSupport::Concern

  included do

    include ActionView::Helpers::NumberHelper

  end
end

Decidim::ViewModel.send(:include, ViewModelExtend)
