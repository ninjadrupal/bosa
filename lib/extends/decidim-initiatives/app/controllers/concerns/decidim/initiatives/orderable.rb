# frozen_string_literal: true
require "active_support/concern"

module OrderableExtend
  extend ActiveSupport::Concern

  included do

    def available_orders
      @available_orders ||= %w(random recent most_voted recently_published answer_date)
    end

    def reorder(initiatives)
      case order
        when "most_voted"
          initiatives.order_by_supports
        when "most_commented"
          initiatives.order_by_most_commented
        when "recent"
          initiatives.order_by_most_recent
        when "recently_published"
          initiatives.order_by_most_recently_published
        when "answer_date"
          initiatives.order_by_answer_date
        else
          initiatives.order_randomly(random_seed)
      end
    end

  end
end

Decidim::Initiatives::Orderable.send(:include, OrderableExtend)
