# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VoteForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create(:organization) }
      let(:initiatives_type) { create(:initiatives_type, organization: organization) }
      let(:initiative) { create(:initiative, organization: organization, scoped_type: create(:initiatives_type_scope, type: initiatives_type)) }

      let(:current_user) { create(:user, organization: initiative.organization) }

      # --- start of bosa patch ---------------------------------------------------------------------------------------
      let(:personal_data) do
        {
          # name_and_surname: "James Morgan McGill",
          # document_number: "01234567A",
          # date_of_birth: 40.years.ago,
          # postal_code: "87111",
          user_scope_id: initiative.scope.id,
          resident: true
        }
      end
      # --- end of bosa patch -----------------------------------------------------------------------------------------

      let(:encrypted_metadata) do
        described_class.from_params(attributes).encrypted_metadata
      end

      # --- start of bosa patch ---------------------------------------------------------------------------------------
      let(:vote_attributes) do
        {
          initiative: initiative,
          signer: current_user
        }
      end
      # --- end of bosa patch -----------------------------------------------------------------------------------------

      let(:attributes) { personal_data.merge(vote_attributes) }
      let(:context) { { current_organization: organization } }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when no personal data is required" do
        context "when personal data is blank" do
          let(:personal_data) { {} }

          it { is_expected.to be_valid }
        end
      end

      context "when personal data is required" do
        let(:initiatives_type) { create(:initiatives_type, organization: organization, collect_user_extra_fields: true) }

        context "when personal data is blank" do
          let(:personal_data) { {} }

          it { is_expected.not_to be_valid }
        end

        context "when personal data is present" do
          it { is_expected.to be_valid }
        end
      end

      describe "#metadata" do
        subject { described_class.from_params(attributes).with_context(context).metadata }

        it { is_expected.to eq(personal_data) }
      end

      describe "#encrypted_metadata" do
        subject { described_class.from_params(attributes).with_context(context).encrypted_metadata }

        context "when no personal data is required" do
          it { is_expected.to be_blank }
        end

        context "when personal data is required" do
          let(:initiatives_type) { create(:initiatives_type, organization: organization, collect_user_extra_fields: true) }

          it { is_expected.not_to eq(personal_data) }

          # --- start of bosa patch -----------------------------------------------------------------------------------
          # [:name_and_surname, :document_number, :date_of_birth, :postal_code].each do |personal_attribute|
          #   it { is_expected.not_to include(personal_data[personal_attribute].to_s) }
          # end
          # --- end of bosa patch -------------------------------------------------------------------------------------
        end
      end

      describe "#decrypted_metadata" do
        subject { described_class.from_params(encrypted_metadata: encrypted_metadata).decrypted_metadata }

        context "when no personal data is required" do
          it { is_expected.to be_blank }
        end

        context "when personal data is required" do
          let(:initiatives_type) { create(:initiatives_type, organization: organization, collect_user_extra_fields: true) }

          it { is_expected.to eq(personal_data) }
        end
      end
    end
  end
end
