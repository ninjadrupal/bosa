# frozen_string_literal: true
require "active_support/concern"

module AdminInitiativesControllerExtend
  extend ActiveSupport::Concern

  # Changes moved from decidim-module-initiatives_nosignature_allowed

  included do
    # GET /admin/initiatives/:id/export_votes
    def export_votes
      enforce_permission_to :export_votes, :initiative, initiative: current_initiative

      votes = current_initiative.votes.map(&:sha1)
      csv_data = CSV.generate(headers: false) do |csv|
        votes.each do |sha1|
          csv << [sha1]
        end
      end

      respond_to do |format|
        format.csv { send_data csv_data, file_name: "votes.csv" }
      end
    end

    # GET /admin/initiatives/:id/export_pdf_signatures.pdf
    def export_pdf_signatures
      enforce_permission_to :export_pdf_signatures, :initiative, initiative: current_initiative

      @votes = current_initiative.votes

      output = render_to_string(
        pdf: "votes_#{current_initiative.id}",
        layout: "decidim/admin/initiatives_votes",
        template: "decidim/initiatives/admin/initiatives/export_pdf_signatures.pdf.erb"
      )
      output = pdf_signature_service.new(pdf: output).signed_pdf if pdf_signature_service

      respond_to do |format|
        format.pdf do
          send_data(output, filename: "votes_#{current_initiative.id}.pdf", type: "application/pdf")
        end
      end
    end

  end
end

Decidim::Initiatives::Admin::InitiativesController.send(:include, AdminInitiativesControllerExtend)
