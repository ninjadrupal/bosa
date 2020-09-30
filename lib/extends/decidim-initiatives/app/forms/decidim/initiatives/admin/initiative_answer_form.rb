# frozen_string_literal: true

require "active_support/concern"

module AdminInitiativeAnswerFormExtend
  extend ActiveSupport::Concern

  included do
    attribute :state, String
    attribute :answer_date, Decidim::Attributes::LocalizedDate

    validates :state, presence: true
    validate :state_validation
    validates :answer_date, presence: true, if: :answer_date_allowed?
    validates :answer_date, date: { before: Date.current.advance(days: 1) }, if: :answer_date_allowed?

    def signature_dates_required?
      @signature_dates_required ||= check_state
    end

    def state_updatable?
      manual_states.include? context.initiative.state
    end

    def uniq_states
      (Decidim::Initiative::AUTOMATIC_STATES + Decidim::Initiative::MANUAL_STATES).uniq.map(&:to_s)
    end

    def manual_states
      Decidim::Initiative::MANUAL_STATES.map(&:to_s)
    end

    def answer_date_allowed?
      return false if state == "published"

      state_updatable?
    end

    def state_validation
      errors.add(:state, :invalid) if !state_updatable? && context.initiative.state != state
      errors.add(:state, :invalid) unless uniq_states.include? state
    end

    private

    def check_state
      manual_states.include? context.initiative.state
    end
  end
end

Decidim::Initiatives::Admin::InitiativeAnswerForm.send(:include, AdminInitiativeAnswerFormExtend)
