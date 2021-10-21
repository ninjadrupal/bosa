# frozen_string_literal: true

shared_examples "update an initiative answer" do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization, state: state) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      initiative: initiative
    )
  end
  let(:signature_end_date) { Date.current + 500.days }
  let(:state) { "published" }
  # --- start of bosa patch -------------------------------------------------------------------------------------------
  let(:form_state) { "examinated" }
  let(:answer_date) { Date.current - 1.month }
  # --- end of bosa patch ---------------------------------------------------------------------------------------------
  let(:form_params) do
    {
      signature_start_date: Date.current + 10.days,
      signature_end_date: signature_end_date,
      answer: { en: "Measured answer" },
      answer_url: "http://decidim.org",
      # --- start of bosa patch ---------------------------------------------------------------------------------------
      state: form_state,
      answer_date: answer_date
      # --- end of bosa patch -----------------------------------------------------------------------------------------
    }
  end
  let(:administrator) { create(:user, :admin, organization: organization) }
  let(:current_user) { administrator }
  let(:command) { described_class.new(initiative, form, current_user) }

  describe "call" do
    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't updates the initiative" do
        command.call

        form_params.each do |key, value|
          expect(initiative[key]).not_to eq(value)
        end
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the initiative" do
        command.call
        initiative.reload

        expect(initiative.answer["en"]).to eq(form_params[:answer][:en])
        expect(initiative.answer_url).to eq(form_params[:answer_url])
      end

      context "when initiative is not published" do
        let(:state) { "validating" }

        it "voting interval remains unchanged" do
          command.call
          initiative.reload

          [:signature_start_date, :signature_end_date].each do |key|
            expect(initiative[key]).not_to eq(form_params[key])
          end
        end
      end

      context "when initiative is published" do
        it "voting interval is updated" do
          command.call
          initiative.reload

          [:signature_start_date, :signature_end_date].each do |key|
            expect(initiative[key]).to eq(form_params[key])
          end
        end

        # --- start of bosa patch -------------------------------------------------------------------------------------
        context "when a answer_date is provided" do
          let(:form_state) { "published" }
          let(:answer_date) { Date.current - 1.day }

          it "doesn't stores the data" do
            command.call
            initiative.reload

            expect(initiative.answer_date).to be_nil
          end

          context "when in a manual state" do
            let(:form_state) { "debatted" }
            let(:answer_date) { Date.current - 1.day }

            it "stores the data" do
              command.call
              initiative.reload

              expect(initiative.answer_date).to eq(answer_date)
            end
          end
        end
        # --- end of bosa patch ---------------------------------------------------------------------------------------
      end
    end
  end
end
