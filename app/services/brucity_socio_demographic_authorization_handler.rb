# frozen_string_literal: true

# Allows to create a form for simple Socio Demographic authorization
class BrucitySocioDemographicAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :residence, String
  attribute :gender, String
  attribute :date_of_birth, Decidim::Attributes::LocalizedDate

  RESIDENCES = %w(haren laeken-nord laken-south neder-over-heembeek pentagone european_district louise_district
    north_district outside_the_city_but_within_brussels-capital_region outside_of_brussels-capital_region).freeze
  GENDERS = %w(man woman undefined).freeze

  validates :residence, inclusion: {in: RESIDENCES}, presence: true
  validates :gender, inclusion: {in: GENDERS}, presence: true
  validates :date_of_birth, presence: true

  def metadata
    super.merge(
      residence: residence,
      gender: gender,
      date_of_birth: date_of_birth
    )
  end

end