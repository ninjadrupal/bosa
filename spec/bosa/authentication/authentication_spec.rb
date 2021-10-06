# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :system do
  let(:organization) {create(:organization)}
  let(:last_user) {Decidim::User.last}
  let(:user_email) {"user@example.org"}
  let(:user_password) {"decidim123456"}

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "when using email and password" do
      it "register a new user, confirm the email and sign in" do
        find(".sign-up-link").click

        perform_enqueued_jobs do
          within ".new_user" do
            fill_in :registration_user_email, with: user_email
            fill_in :registration_user_name, with: "User Example"
            fill_in :registration_user_nickname, with: "user_example"
            fill_in :registration_user_password, with: user_password
            fill_in :registration_user_password_confirmation, with: user_password
            check :registration_user_tos_agreement
            check :registration_user_newsletter
            find("*[type=submit]").click
          end
          expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
        end

        visit last_email_link
        expect(page).to have_content("successfully confirmed")
        expect(last_user).to be_confirmed

        find(".sign-in-link").click
        within ".new_user" do
          fill_in :session_user_email, with: user_email
          fill_in :session_user_password, with: user_password
          find("*[type=submit]").click
        end
        expect(page).to have_content("Signed in successfully")
        expect(page).to have_content("User Example")
      end
    end

    context "when sign up is disabled" do
      let(:organization) {create(:organization, users_registration_mode: :existing)}

      it "redirects to the sign in when accessing the sign up page" do
        visit decidim.new_user_registration_path
        expect(page).not_to have_content("Sign Up")
        expect(page).to have_current_path("/users/sign_in")
      end

      it "don't allow the user to sign up" do
        find(".sign-in-link").click
        expect(page).not_to have_content("Create an account")
      end
    end
  end

  describe "Sign In" do
    context "unconfirmed user" do
      let(:user) {create(:user, password: user_password, organization: organization)}

      describe "sign in" do
        it "doesn't allow to authenticate an existing user" do
          find(".sign-in-link").click

          within ".new_user" do
            fill_in :session_user_email, with: user.email
            fill_in :session_user_password, with: user_password
            find("*[type=submit]").click
          end

          expect(page).to have_content("You have to confirm your email address before continuing.")
          expect(page).not_to have_content(user.name)
        end
      end
    end

    context "confirmed user" do
      let(:user) {create(:user, :confirmed, password: user_password, organization: organization)}

      describe "sign in" do
        it "authenticates an existing user" do
          find(".sign-in-link").click

          within ".new_user" do
            fill_in :session_user_email, with: user.email
            fill_in :session_user_password, with: user_password
            find("*[type=submit]").click
          end

          expect(page).to have_content("Signed in successfully")
          expect(page).to have_content(user.name)
        end
      end
    end
  end

  describe "Not logged in" do
    let(:user) {create(:user, :confirmed, password: user_password, organization: organization)}

    it "with wrong data it shows an error message" do
      find(".sign-in-link").click

      within ".new_user" do
        fill_in :session_user_email, with: "wrong_user@example.org"
        fill_in :session_user_password, with: user_password
        find("*[type=submit]").click
      end

      expect(page).to have_content("Invalid Email or password.")
      expect(page).not_to have_content(user.name)
    end

    it "can't access profile page" do
      visit decidim.account_path

      expect(page).to have_content("You need to sign in or sign up before continuing.")
      expect(page).not_to have_content(user.name)
    end
  end

  describe "Resend confirmation instructions" do
    let(:user) do
      perform_enqueued_jobs {create(:user, organization: organization)}
    end

    it "sends an email with the instructions" do
      visit decidim.new_user_confirmation_path

      within ".new_user" do
        fill_in :confirmation_user_email, with: user.email
        perform_enqueued_jobs {find("*[type=submit]").click}
      end

      expect(emails.count).to eq(2)
      expect(page).to have_content("receive an email with instructions")
    end
  end

  describe "Sign Out" do
    let(:user) {create(:user, :confirmed, password: user_password, organization: organization)}

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "signs out the user" do
      within_user_menu do
        find(".sign-out-link").click
      end

      expect(page).to have_content("Signed out successfully.")
      expect(page).to have_no_content(user.name)
    end
  end


end
