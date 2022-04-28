require 'rspec'

describe OrganizationExtend do

  let(:organization_1) { create(:organization, omniauth_settings: {
    "omniauth_settings_csam_enabled" => false,
    "omniauth_settings_saml_enabled" => false,
    "omniauth_settings_twitter_enabled" => false, # enabled by default in secrets.yml
    "omniauth_settings_facebook_enabled" => false,
    "omniauth_settings_google_oauth2_enabled" => true,
    "omniauth_settings_google_oauth2_client_id" => "encrypted_stuff",
    "omniauth_settings_google_oauth2_client_secret" => "encrypted_stuff",
  }) }
  let(:organization_2) { create(:organization, omniauth_settings: {
    "omniauth_settings_twitter_enabled" => true,
  }) }

  it 'should use the cache to avoid decrypting twice the same data' do

    # Using stubs as we don't need actual decryption
    allow(organization_1).to receive(:tenant_enabled_providers) { {} }
    allow(organization_2).to receive(:tenant_enabled_providers) { {} }

    expected_org_1_providers = { :google_oauth2 => { :enabled => true } }
    org_1_cache_key = "#{organization_1.cache_key_with_version}/enabled_omniauth_providers"

    expect(Rails.cache.exist? org_1_cache_key).to be false
    expect(organization_1.enabled_omniauth_providers).to eq(expected_org_1_providers)
    expect(Rails.cache.exist? org_1_cache_key).to be true
    expect(Rails.cache.read org_1_cache_key).to eq(expected_org_1_providers)

    expect(organization_1.enabled_omniauth_providers).to eq(expected_org_1_providers)
    expect(organization_1).to have_received(:tenant_enabled_providers).exactly(1).times

    expect(organization_2.enabled_omniauth_providers).to eq({ :facebook => { :enabled => true }, :google_oauth2 => { :enabled => true }, :twitter => { :enabled => true } })
    expect(organization_2).to have_received(:tenant_enabled_providers).exactly(1).times
  end

end
