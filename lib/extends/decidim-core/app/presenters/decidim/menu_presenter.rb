# frozen_string_literal: true
require "active_support/concern"

module MenuPresenterExtend
  extend ActiveSupport::Concern

  included do

    #
    # Initializes a menu for presentation
    #
    # @param name [Symbol] The name of the menu registry to be rendered
    # @param view [ActionView::Base] The view scope to render the menu
    # @param class_name [String] CSS class for the nav component
    # @param options [Hash] The rendering options for the menu entries
    #
    def initialize(name, view, class_name, options = {})
      @name = name
      @view = view
      @class_name = class_name
      @options = options
    end

    def render
      content_tag :nav, class: @class_name do
        content_tag :ul do
          safe_join(menu_items)
        end
      end
    end

  end
end

Decidim::MenuPresenter.send(:include, MenuPresenterExtend)
