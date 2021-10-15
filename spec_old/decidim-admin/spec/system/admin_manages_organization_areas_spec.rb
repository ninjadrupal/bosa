# frozen_string_literal: true

require "spec_helper"

describe "Organization Areas", type: :system do
  include Decidim::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
  end

  describe "Managing areas" do
    let!(:area_type) { create(:area_type, organization: admin.organization) }

    before do
      login_as admin, scope: :user
      visit decidim_admin.root_path
      click_link "Settings"
      click_link "Areas"
    end

    it "can create new areas" do
      click_link "Add"

      within ".new_area" do
        fill_in_i18n :area_name, "#area-name-tabs", en: "My area",
                                                    fr: "Ma zone",
                                                    nl: "Mijn gebied"
        select area_type.name["en"], from: :area_area_type_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My area")
      end
    end

    context "with existing areas" do
      let!(:area) { create(:area, organization: organization, area_type: area_type) }

      before do
        visit current_path
      end

      it "lists all the areas for the organization" do
        within "#areas table" do
          expect(page).to have_content(translated(area.name, locale: :en))
          expect(page).to have_content(translated(area.area_type.name, locale: :en))
        end
      end

      context "when edit area" do
        before do
          within find("tr", text: translated(area.name)) do
            click_link "Edit"
          end
        end

        it "edits area" do
          within ".edit_area" do
            fill_in_i18n :area_name, "#area-name-tabs", en: "Another area",
                                                        fr: "Un autre zone",
                                                        nl: "Een ander gebied"
            find("*[type=submit]").click
          end

          expect(page).to have_admin_callout("successfully")

          within "table" do
            expect(page).to have_content("Another area")
          end
        end

        it "can select area's color" do
          expect(page).to have_content("Area color")
        end

        it "can select area's logo" do
          expect(page).to have_content("Logo")
        end
      end

      it "can delete them" do
        click_delete_area

        expect(page).to have_admin_callout("successfully")

        within ".card-section" do
          expect(page).to have_no_content(translated(area.name))
        end
      end

      context "when a participatory space associated to a given area exist" do
        let!(:process) { create(:participatory_process, organization: area.organization, area: area) }

        it "can not be deleted" do
          click_delete_area
          expect(area.reload.destroyed?).to be false
          expect(page).to have_admin_callout("Area has dependent spaces")
        end
      end
    end
  end

  private

  def click_delete_area
    within find("tr", text: translated(area.name)) do
      accept_confirm { click_link "Destroy" }
    end
  end
end
