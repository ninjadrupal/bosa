# This migration comes from decidim_verifications_omniauth (originally 20191203162949)
# frozen_string_literal: tru

# This migration comes from decidim (originally 20191004194247)
class AddDecidimVerificationsOmniauthEncryptedMetadataToAuthorizations < ActiveRecord::Migration[5.2]
  def change
    #
    # It was already migrated in a previous migration: 20191203162949_add_encrypted_metadata_to_authorizations.decidim
    # Leave current migration here to skip it next time the task will move missing migrations (bundle exec rails decidim_verifications_omniauth:install:migrations)
    #
    # add_column :decidim_authorizations, :encrypted_metadata, :text
    # Decidim::Authorization.find_each do |authorization|
    #   authorization.encrypted_metadata = Decidim::MetadataEncryptor.new(
    #     uid: authorization.unique_id
    #   ).encrypt(authorization.metadata)
    # end
    # remove_column :decidim_authorizations, :metadata
  end
end
