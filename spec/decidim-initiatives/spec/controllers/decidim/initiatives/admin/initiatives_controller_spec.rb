# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::InitiativesController, type: :controller do
  routes { Decidim::Initiatives::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, organization: organization) }
  let!(:created_initiative) { create(:initiative, :created, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end

  context "when GET export" do
    context "and user" do
      before do
        sign_in user, scope: :user
      end

      it "is not allowed" do
        get :export, params: { format: :csv }
        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    context "and admin" do
      before do
        sign_in admin_user, scope: :user
      end

      it "is allowed" do
        get :export, params: { format: :csv }
        expect(flash[:alert]).to be_nil
        expect(response).to have_http_status(:found)
      end
    end
  end
end
