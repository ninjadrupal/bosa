# frozen_string_literal: true

require "active_support/concern"

module FormBuilderExtend
  extend ActiveSupport::Concern

  included do
    def areas_select(name, collection, options = {}, html_options = {})
      selectables = if collection.first.is_a?(Decidim::Area)
                      assemblies = collection
                                   .map { |a| [a.name[I18n.locale.to_s], a.id] }
                                   .sort_by { |arr| arr[0] }

                      @template.options_for_select(
                        assemblies,
                        selected: options[:selected]
                      )
                    else
                      @template.option_groups_from_collection_for_select(
                        collection,
                        :areas,
                        :translated_name,
                        :id,
                        :translated_name,
                        selected: options[:selected]
                      )
                    end

      select(name, selectables, options, html_options)
    end

    def upload(attribute, options = {})
      self.multipart = true
      options[:optional] = options[:optional].nil? ? true : options[:optional]

      file = object.send attribute
      template = ""
      template += label(attribute, label_for(attribute) + required_for_attribute(attribute))
      if options[:accept].present?
        template += @template.file_field @object_name, attribute, accept: options.delete(:accept)
      else
        template += @template.file_field @object_name, attribute
      end

      if file_is_image?(file)
        template += if file.present?
                      @template.content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                    else
                      @template.content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                    end
        template += @template.link_to @template.image_tag(file.url), file.url, target: "_blank", rel: "noopener"
      elsif file_is_present?(file)
        template += @template.label_tag I18n.t("current_file", scope: "decidim.forms")
        template += @template.link_to file.file.filename, file.url, target: "_blank", rel: "noopener"
      end

      if file_is_present?(file)
        if options[:optional]
          template += content_tag :div, class: "field" do
            safe_join([
                        @template.check_box(@object_name, "remove_#{attribute}"),
                        label("remove_#{attribute}", I18n.t("remove_this_file", scope: "decidim.forms"))
                      ])
          end
        end
      end

      if object.errors[attribute].any?
        template += content_tag :p, class: "is-invalid-label" do
          safe_join object.errors[attribute], "<br/>".html_safe
        end
      end

      template.html_safe
    end
  end
end

Decidim::FormBuilder.send(:include, FormBuilderExtend)
