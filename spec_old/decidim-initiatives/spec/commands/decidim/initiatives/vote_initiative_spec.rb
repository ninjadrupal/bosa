# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe VoteInitiative do
      let(:form_klass) { VoteForm }
      let(:organization) { create(:organization) }
      let(:initiative) { create(:initiative, organization: organization) }

      let(:current_user) { create(:user, :confirmed, organization: initiative.organization) }
      let(:form) do
        form_klass
          .from_params(
            form_params
          ).with_context(current_organization: organization)
      end

      let(:form_params) do
        {
          initiative: initiative,
          signer: current_user
        }
      end

      let(:personal_data_params) do
        {
          # name_and_surname: ::Faker::Name.name,
          # document_number: ::Faker::IDNumber.spanish_citizen_number,
          # date_of_birth: ::Faker::Date.birthday(18, 40),
          # postal_code: ::Faker::Address.zip_code,
          user_scope_id: nil,
          resident: true
        }
      end

      describe "User votes initiative" do
        let(:command) { described_class.new(form) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "creates a vote" do
          expect do
            command.call
          end.to change(InitiativesVote, :count).by(1)
        end

        it "increases the vote counter by one" do
          expect do
            command.call
            initiative.reload
          end.to change(initiative, :online_votes_count).by(1)
        end

        it "notifies the creation" do
          follower = create(:user, organization: initiative.organization)
          create(:follow, followable: initiative.author, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.initiative_endorsed",
              event_class: Decidim::Initiatives::EndorseInitiativeEvent,
              resource: initiative,
              followers: [follower]
            )

          command.call
        end

        context "when a new milestone is completed" do
          let(:initiative) do
            create(:initiative,
                   organization: organization,
                   scoped_type: create(
                     :initiatives_type_scope,
                     supports_required: 4,
                     type: create(:initiatives_type, organization: organization)
                   ))
          end

          let!(:follower) { create(:user, organization: initiative.organization) }
          let!(:follow) { create(:follow, followable: initiative, user: follower) }

          before do
            create(:initiative_user_vote, initiative: initiative)
            create(:initiative_user_vote, initiative: initiative)
          end

          it "notifies the followers" do
            expect(Decidim::EventsManager).to receive(:publish)
              .with(kind_of(Hash))

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.initiatives.milestone_completed",
                event_class: Decidim::Initiatives::MilestoneCompletedEvent,
                resource: initiative,
                affected_users: [initiative.author],
                followers: [follower],
                extra: { percentage: 75 }
              )

            command.call
          end

          it "sends notification with email" do
            expect do
              perform_enqueued_jobs { command.call }
            end.to change(emails, :count).by(1) #3)

            expect(last_email_body).to include("has achieved the 75% of signatures")
          end
        end

        context "when support threshold is reached" do
          let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
          let(:initiative) do
            create(:initiative,
                   organization: organization,
                   scoped_type: create(
                     :initiatives_type_scope,
                     supports_required: 4,
                     type: create(:initiatives_type, organization: organization)
                   ))
          end

          before do
            create(:initiative_user_vote, initiative: initiative, hash_id: new_form.hash_id)
            create(:initiative_user_vote, initiative: initiative, hash_id: new_form.hash_id)
            create(:initiative_user_vote, initiative: initiative, hash_id: new_form.hash_id)
          end

          it "sends notifications" do
            expect(Decidim::EventsManager).to receive(:publish).with(
              event: "decidim.events.initiatives.initiative_endorsed",
              event_class: Decidim::Initiatives::EndorseInitiativeEvent,
              resource: initiative,
              followers: initiative.author.followers
            )

            expect(Decidim::EventsManager).to receive(:publish).with(
              event: "decidim.events.initiatives.milestone_completed",
              event_class: Decidim::Initiatives::MilestoneCompletedEvent,
              resource: initiative,
              affected_users: [initiative.author],
              followers: initiative.followers - [initiative.author],
              extra: {
                percentage: 100
              }
            )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.initiatives.support_threshold_reached",
                event_class: Decidim::Initiatives::Admin::SupportThresholdReachedEvent,
                resource: initiative,
                followers: [admin]
              )

            initiative.votable_initiative_type_scopes.each do |type_scope|
              expect(Decidim::EventsManager).to receive(:publish).with(
                event: "decidim.events.initiatives.support_threshold_reached_for_scope",
                event_class: Decidim::Initiatives::SupportThresholdReachedForScopeEvent,
                resource: initiative,
                affected_users: [initiative.author],
                extra: {
                  scope: type_scope.scope
                }
              )

              expect(Decidim::EventsManager).to receive(:publish).with(
                event: "decidim.events.initiatives.admin.support_threshold_reached_for_scope",
                event_class: Decidim::Initiatives::Admin::SupportThresholdReachedForScopeEvent,
                resource: initiative,
                affected_users: [admin],
                extra: {
                  scope: type_scope.scope
                }
              )
            end

            command.call
          end

          it "sends notification with email" do
            expect do
              perform_enqueued_jobs { command.call }
            end.to change(emails, :count).by(3) #4)

            expect(email_body(emails[0])).to include("has achieved the 100% of signatures")
            # expect(email_body(emails[1])).to include("has reached the signatures threshold")
            expect(email_body(emails[1])).to include("has reached the minimum number of signatures for the #{initiative.scope.name[I18n.locale.to_s]} Region")
            expect(email_body(emails[2])).to include("has reached the minimum number of signatures for the #{initiative.scope.name[I18n.locale.to_s]} Region")
          end

          context "when more votes are added" do
            before do
              create(:initiative_user_vote, initiative: initiative)
            end

            it "doesn't notifies the admins" do
              expect(Decidim::EventsManager).to receive(:publish)
                                                  .with(kind_of(Hash)).once

              expect(Decidim::EventsManager)
                .not_to receive(:publish)
                          .with(
                            event: "decidim.events.initiatives.support_threshold_reached",
                            event_class: Decidim::Initiatives::Admin::SupportThresholdReachedEvent,
                            resource: initiative,
                            followers: [admin]
                          )

              expect do
                perform_enqueued_jobs { command.call }
              end.to change(emails, :count).by(0)
            end
          end
        end

        context "when initiative type requires extra user fields" do
          let(:initiative) do
            create(
              :initiative,
              :with_user_extra_fields_collection,
              organization: organization
            )
          end
          let(:form_with_personal_data) do
            form_klass.from_params(form_params.merge(personal_data_params)).with_context(current_organization: organization)
          end

          let(:invalid_command) { described_class.new(form) }
          let(:command_with_personal_data) { described_class.new(form_with_personal_data) }

          it "broadcasts invalid when form doesn't contain personal data" do
            expect { invalid_command.call }.to broadcast :invalid
          end

          it "broadcasts ok when form contains personal data" do
            expect { command_with_personal_data.call }.to broadcast :ok
          end

          it "stores encrypted user personal data in vote" do
            command_with_personal_data.call
            vote = InitiativesVote.last
            expect(vote.encrypted_metadata).to be_present
            # expect(vote.decrypted_metadata).to eq personal_data_params
            expect(vote.decrypted_metadata).to eq({ user_scope_id: nil, resident: true })
          end

          context "when another signature exists with the same hash_id" do
            before do
              create(:initiative_user_vote, initiative: initiative, scope: organization.scopes.first, hash_id: form_with_personal_data.hash_id)
            end

            it "broadcasts invalid" do
              expect { command_with_personal_data.call }.to broadcast :invalid
            end
          end

        end

        def new_form
          p = personal_data_params.merge(
            {
              name_and_surname: ::Faker::Name.name,
              document_number: ::Faker::IDNumber.spanish_citizen_number
            }
          )
          form_klass.from_params(form_params.merge(p)).with_context(current_organization: organization)
        end
      end
    end
  end
end
