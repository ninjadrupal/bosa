# frozen_string_literal: true

require "active_support/concern"

module InitiativesVoteExtend
  extend ActiveSupport::Concern

  included do
    belongs_to :scope,
               foreign_key: "decidim_scope_id",
               class_name: "Decidim::Scope",
               optional: true

    clear_validators!
    validates :initiative, uniqueness: { scope: [:author, :scope, :hash_id] }

    scope :for_scope, ->(scope) { where(scope: scope) }

    def self.user_collection(author)
      where(decidim_author_id: author.id)
    end

    def self.export_serializer
      Decidim::Initiatives::DataPortabilityInitiativesVoteSerializer
    end

    def self.data_portability_images(user); end

    # Public: Generates a hashed representation of the initiative support.
    #
    # Used when exporting the votes as CSV.
    def sha1
      title = translated_attribute(initiative.title)
      description = translated_attribute(initiative.description)

      Digest::SHA1.hexdigest "#{authorization_unique_id}#{title}#{description}"
    end

    def decrypted_metadata
      @decrypted_metadata ||= encrypted_metadata ? encryptor.decrypt(encrypted_metadata) : {}
    end

    private

    def encryptor
      @encryptor ||= Decidim::Initiatives::DataEncryptor.new(secret: "personal user metadata")
    end

    def update_counter_cache
      initiative.update_online_votes_counters
    end
  end
end

Decidim::InitiativesVote.send(:include, InitiativesVoteExtend)
