# frozen_string_literal: true

require "active_support/concern"

module ActiveRecordSessionStoreExtend
  extend ActiveSupport::Concern

  included do

    def serialize(data)
      if data
        # Fix storing attachment on create initiative/suggestion to prevent issues with non utf characters in filename
        data = replace_non_ascii_chars(data, 'initiative')
        data = replace_non_ascii_chars(data, 'suggestion')

        serializer_class.dump(data)
      end
    end

    private

    def replace_non_ascii_chars(data, attr)
      file = data.dig(attr, 'attachment').try(:file)
      if file.present? && file.is_a?(ActionDispatch::Http::UploadedFile)
        encoding_options = {
          invalid: :replace, # Replace invalid byte sequences
          undef: :replace, # Replace anything not defined in ASCII
          replace: '', # Use a blank for those replacements
          universal_newline: true # Always break lines with \n
        }
        data[attr]['attachment'].file.original_filename = file.original_filename.encode(Encoding.find('ASCII'), encoding_options)
        data[attr]['attachment'].file.headers = file.headers.encode(Encoding.find('ASCII'), encoding_options)
      end

      data
    end

  end
end

ActiveRecord::SessionStore::ClassMethods.send(:include, ActiveRecordSessionStoreExtend)
