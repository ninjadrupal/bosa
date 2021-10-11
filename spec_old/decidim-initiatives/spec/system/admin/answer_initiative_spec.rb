# frozen_string_literal: true

require "spec_helper"

describe "User answers the initiative", type: :system do
  include_context "when admins initiative"

  shared_examples_for "editable signature dates" do
    it "signature dates can be edited in answer" do
      page.find(".action-icon--answer").click

      within ".edit_initiative_answer" do
        fill_in_i18n_editor(
          :initiative_answer,
          "#initiative-answer-tabs",
          en: "An answer",
          fr: "Una respuesta",
          nl: "Una resposta"
        )
        expect(page).to have_css("#initiative_state", visible: false)
        expect(page).to have_css("#initiative_signature_start_date")
        expect(page).to have_css("#initiative_signature_end_date")
        expect(page).to have_css("#initiative_state")
        expect(page).to have_css("#initiative_answer_date")

        expect(find("#initiative_answer_date").value).to eq(I18n.l(Date.current, format: :decidim_short))

        fill_in :initiative_answer_date, with: 1.day.ago.strftime("%dd/%mm/%Y")
        fill_in :initiative_signature_start_date, with: 2.days.ago
      end

      submit_and_validate
    end
  end

  def submit_and_validate(message = "successfully")
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content(message)
    end
  end

  context "when user is author" do
    before do
      switch_to_host(organization.host)
      login_as author, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "answer is forbidden" do
      expect(page).to have_no_css(".action-icon--answer")

      visit decidim_admin_initiatives.edit_initiative_answer_path(initiative)

      expect(page).to have_content("You are not authorized")
    end
  end

  context "when user is admin" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.initiatives_path
    end

    it "answer is allowed" do
      expect(page).to have_css(".action-icon--answer")
      page.find(".action-icon--answer").click

      within ".edit_initiative_answer" do
        fill_in_i18n_editor(
          :initiative_answer,
          "#initiative-answer-tabs",
          en: "An answer",
          fr: "Una respuesta",
          nl: "Una resposta"
        )
      end

      submit_and_validate
    end

    context "when initiative is in published state" do
      before do
        initiative.published!
      end

      context "and signature dates are editable" do
        it "can be edited in answer" do
          page.find(".action-icon--answer").click

          within ".edit_initiative_answer" do
            fill_in_i18n_editor(
              :initiative_answer,
              "#initiative-answer-tabs",
              en: "An answer",
              fr: "Una respuesta",
              nl: "Una resposta"
            )
            expect(page).to have_css("#initiative_signature_start_date")
            expect(page).to have_css("#initiative_signature_end_date")
            expect(page).to have_css("#initiative_state")
            expect(page).to have_css("#initiative_answer_date", visible: false)

            fill_in :initiative_signature_start_date, with: 1.day.ago
          end

          submit_and_validate
        end
      end

      context "when dates are invalid" do
        it "returns an error message" do
          page.find(".action-icon--answer").click

          within ".edit_initiative_answer" do
            fill_in_i18n_editor(
              :initiative_answer,
              "#initiative-answer-tabs",
              en: "An answer",
              fr: "Una respuesta",
              nl: "Una resposta"
            )
            expect(page).to have_css("#initiative_signature_start_date")
            expect(page).to have_css("#initiative_signature_end_date")

            fill_in :initiative_signature_start_date, with: 1.month.since(initiative.signature_end_date)
          end

          submit_and_validate("error")
        end
      end
    end

    context "when initiative is in examinated state" do
      before do
        initiative.examinated!
      end

      it_behaves_like "editable signature dates"
    end

    context "when initiative is in debatted state" do
      before do
        initiative.debatted!
      end

      it_behaves_like "editable signature dates"
    end

    context "when initiative is in classified state" do
      before do
        initiative.classified!
      end

      it_behaves_like "editable signature dates"
    end

    context "when initiative is in validating state" do
      before do
        initiative.validating!
      end

      it "signature dates are not displayed" do
        page.find(".action-icon--answer").click

        within ".edit_initiative_answer" do
          expect(page).to have_no_css("#initiative_signature_start_date")
          expect(page).to have_no_css("#initiative_signature_end_date")
          expect(page).to have_no_css("#initiative_state")
          expect(page).to have_no_css("#initiative_answer_date")
        end
      end
    end

    context "when admin changes initiative state" do
      before do
        initiative.debatted!
      end

      context "when debatted to classified" do
        before do
          page.find(".action-icon--answer").click
        end

        it "set the signature_end_date to current date" do
          original_signature_end_date = find("#initiative_signature_end_date").value

          select "Classified", from: :initiative_state

          expect(find("#initiative_signature_end_date").value).not_to eq(original_signature_end_date)
          expect(find("#initiative_signature_end_date").value).to eq(I18n.l(Date.current, format: :decidim_short))
        end
      end

      context "when debatted to classified then debatted" do
        before do
          page.find(".action-icon--answer").click
        end

        it "set the signature_end_date to current date" do
          original_signature_end_date = find("#initiative_signature_end_date").value

          select "Classified", from: :initiative_state

          expect(find("#initiative_signature_end_date").value).not_to eq(original_signature_end_date)
          expect(find("#initiative_signature_end_date").value).to eq(I18n.l(Date.current, format: :decidim_short))

          select "Debatted", from: :initiative_state

          expect(find("#initiative_signature_end_date").value).to eq(original_signature_end_date)
          expect(find("#initiative_signature_end_date").value).not_to eq(I18n.l(Date.current, format: :decidim_short))
        end
      end
    end

  end
end
