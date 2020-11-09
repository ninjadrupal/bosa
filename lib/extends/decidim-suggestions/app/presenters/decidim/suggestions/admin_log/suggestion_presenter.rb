# frozen_string_literal: true

require "active_support/concern"

module AdminLogSuggestionPresenterExtend
  extend ActiveSupport::Concern

  included do

    private

    def diff_fields_mapping
      {
        state: :string,
        published_at: :date,
        signature_start_date: :date,
        signature_end_date: :date,
        description: :i18n,
        title: :i18n,
        hashtag: :string,
        offline_votes: :integer
      }
    end

  end
end

Decidim::Suggestions::AdminLog::SuggestionPresenter.send(:include, AdminLogSuggestionPresenterExtend)
