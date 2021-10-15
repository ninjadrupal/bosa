# frozen_string_literal: true

require "spec_helper"
include ActionView::Helpers::NumberHelper

describe "Initiative signing", type: :system do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:confirmed_user) { create(:user, :confirmed, organization: organization) }
  let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
  let(:initiatives_type) { create(:initiatives_type, :only_global_scope_enabled, :undo_online_signatures_enabled, organization: organization) }
  let(:scope) { create(:initiatives_type_scope, scope: nil, type: initiatives_type) }
  let(:initiative) { create(:initiative, :published, organization: organization, scoped_type: scope) }

  before do
    allow(Decidim::Initiatives)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
  end

  context "when the user has not signed the initiative" do
    context "when online signatures are enabled for site" do
      context "when initative type only allows In-person signatures" do
        let(:initiative) { create(:initiative, :published, organization: organization, signature_type: "offline") }

        it "voting disabled message is shown" do
          visit decidim_initiatives.initiative_path(initiative)

          expect(page).to have_content("SIGNING DISABLED")
        end
      end
    end
  end

  context "when the user has signed the initiative and unsigns it" do
    context "when initiative type has unvotes disabled" do
      let(:initiatives_type) { create(:initiatives_type, :only_global_scope_enabled, :undo_online_signatures_disabled, organization: organization) }

      it "unsigning initiative is disabled" do
        vote_initiative
        within ".view-side" do
          expect(page).to have_content(signature_text(1))
          expect(page).to have_button("Already signed", disabled: true)
          click_button "Already signed", disabled: true
          expect(page).to have_content(signature_text(1))
        end
      end
    end

    it "removes the signature" do
      vote_initiative

      within ".view-side" do
        expect(page).to have_content(signature_text(1))
        click_button "Already signed"
        expect(page).to have_content(signature_text(0))
      end
    end
  end

  context "when scope of initiative_type_scope is defined" do
    let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

    it "shows the scope name" do
      visit decidim_initiatives.initiative_path(initiative)

      within ".progress__bar__title" do
        expect(page).not_to have_content(signature_text(1))
        expect(page).not_to have_content(signature_text(2))
        expect(page).to have_content(translated(initiative.scoped_type.scope.name).upcase)
      end
    end
  end

  context "when the initiative type has permissions to vote" do
    before do
      initiative.type.create_resource_permission(
        permissions: {
          "vote" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => { "options" => {} },
              "another_dummy_authorization_handler" => { "options" => {} }
            }
          }
        }
      )
    end

    context "and has not signed the initiative yet" do
      context "and is not verified" do
        it "signin initiative is disabled" do
          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content("VERIFY YOUR ACCOUNT")
          end
          click_button "Verify your account"
          sleep 10
          expect(page).to have_text("Authorization required")
        end
      end

      context "and is verified" do
        before do
          create(:authorization, name: "dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
          create(:authorization, name: "another_dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
        end

        it "votes as themselves" do
          vote_initiative
        end
      end
    end

    context "and has signed the initiative" do
      before do
        initiative.votes.create(author: confirmed_user)
      end

      context "and is not verified" do
        let(:initiatives_type) { create(:initiatives_type, :only_global_scope_enabled, :undo_online_signatures_disabled, organization: organization) }

        it "unsigning initiative is disabled" do
          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content(signature_text(1))
            expect(page).to have_button("Already signed", disabled: true)
            click_button "Already signed", disabled: true
            expect(page).to have_content(signature_text(1))
          end
        end
      end
    end
  end

  context "when the initiative requires user extra fields collection to be signed" do
    let(:initiatives_type) { create(:initiatives_type, :only_global_scope_enabled, :with_user_extra_fields_collection, :undo_online_signatures_disabled, organization: organization) }

    let!(:other_scopes) { create_list(:scope, 5, organization: organization) }

    context "when the user has not signed the initiative yet and signs it" do
      it "adds the signature" do
        vote_initiative
      end

      it "vote is forbidden unless personal data is filled" do
        visit decidim_initiatives.initiative_path(initiative)

        within ".view-side" do
          expect(page).to have_content(signature_text(0))
          click_on "Sign"
        end
        click_button "Continue"

        expect(page).to have_content "error"

        visit decidim_initiatives.initiative_path(initiative)
        within ".view-side" do
          expect(page).to have_content(signature_text(0))
          click_on "Sign"
        end
      end
    end
  end

  def vote_initiative(user_name: nil)
    visit decidim_initiatives.initiative_path(initiative)

    within ".view-side" do
      expect(page).to have_content(signature_text(0))
      click_on "Sign"
    end

    if user_name.present?
      within "#user-identities" do
        click_on user_name
      end
    end

    if has_content?("Complete your data")
      select translated(other_scopes.first.name), from: "initiatives_vote_user_scope_id"
      check "initiatives_vote_resident"

      click_button "Continue"

      expect(page).to have_content("initiative has been successfully signed")
      click_on "Back to initiative"
    end

    within ".view-side" do
      expect(page).to have_content(signature_text(1))
    end
  end

  def signature_text(number)
    return "1/#{number_with_delimiter(initiative.supports_required, delimiter: t(".decidim.progress_bar.number_delimiter"))}\nSIGNATURE" if number == 1

    "#{number}/#{number_with_delimiter(initiative.supports_required, delimiter: t(".decidim.progress_bar.number_delimiter"))}\nSIGNATURES"
  end
end
