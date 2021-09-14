# frozen_string_literal: true

# Allows to create a form for simple Socio Demographic authorization
class SocioDemographicAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :category, String
  attribute :gender, String
  attribute :age, String
  attribute :study_level, String
  attribute :scope_id, Integer
  # attribute :postal_code, String

  CATEGORIES = %w(citizen association academic_environment local_authorities).freeze
  GENDERS = %w(man woman undefined).freeze
  AGE_SLICES = %w(16-25 26-35 36-45 46-55 56-65 65+).freeze

  validates :category, inclusion: {in: CATEGORIES, if: proc {|x| x.category.present?}}, presence: false
  validates :gender, inclusion: {in: GENDERS, if: proc {|x| x.gender.present?}}, presence: false
  validates :age, inclusion: {in: AGE_SLICES, if: proc {|x| x.age.present?}}, presence: false
  validates :scope_id, presence: true,
            format: {with: /\A\d+\z/, message: I18n.t("errors.messages.integer_only"), if: proc {|h| !h.scope_id.nil? && valid_scope}}
  # validates :postal_code, presence: false, format: {with: /\A[0-9]*\z/},
  #           if: proc {|h| !h.postal_code.present? && valid_postal_code}

  def metadata
    super.merge(
      category: category,
      gender: gender,
      age: age,
      study_level: study_level,
      scope_id: scope_id,
      # postal_code: postal_code
    )
  end

  private

  def valid_scope
    errors.add(:scope_id, :invalid) if Decidim::Scope.where(id: scope_id).empty?
  end

  # def valid_postal_code
  #   region_codes = Decidim::Organization::INITIATIVES_SETTINGS_ALLOWED_REGIONS.slice(*allowed_regions).values.pluck(:municipalities).flatten.map {|m| m[:idM]}.uniq
  #   errors.add(:postal_code, :not_in_district) unless region_codes.include?(postal_code)
  # end
end