# frozen_string_literal: true

# Allows to create a form for simple Socio Demographic authorization
class SocioDemographicAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :category, String
  attribute :gender, String
  attribute :age, String
  attribute :study_level, String
  attribute :scope_id, Integer

  CATEGORIES = %w(citizen association academic_environment local_authorities).freeze
  GENDERS = %w(man woman undefined).freeze
  AGE_SLICES = %w(16-25 26-35 36-45 46-55 56-65 65+).freeze

  validates :category, inclusion: {in: CATEGORIES, if: proc {|x| x.category.present?}}, presence: false
  validates :gender, inclusion: {in: GENDERS, if: proc {|x| x.gender.present?}}, presence: false
  validates :age, inclusion: {in: AGE_SLICES, if: proc {|x| x.age.present?}}, presence: false
  validates :scope_id, presence: true,
            format: {with: /\A\d+\z/, message: I18n.t("errors.messages.integer_only"), if: proc {|h| !h.scope_id.nil? && valid_scope}}

  def metadata
    super.merge(
      category: category,
      gender: gender,
      age: age,
      study_level: study_level,
      scope_id: scope_id,
    )
  end

  private

  def valid_scope
    errors.add(:scope_id, :invalid) if Decidim::Scope.where(id: scope_id).empty?
  end

end