Decidim.menu :admin_settings_menu do |menu|
  menu.item I18n.t("menu.configuration", scope: "decidim.admin"),
            decidim_admin.edit_organization_path,
            position: 1,
            active: [%w(decidim/admin/organization), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.appearance", scope: "decidim.admin"),
            decidim_admin.edit_organization_appearance_path,
            position: 2,
            active: [%w(decidim/admin/organization_appearance), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.homepage", scope: "decidim.admin"),
            decidim_admin.edit_organization_homepage_path,
            position: 3,
            active: [%w(decidim/admin/organization_homepage), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("admin.menu.navbar_links", scope: "decidim_navbar_links"),
            decidim_admin_navbar_links.navbar_links_path,
            position: 3.1,
            active: [%w(decidim/admin/navbar_links), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.scopes", scope: "decidim.admin"),
            decidim_admin.scopes_path,
            position: 4,
            active: [%w(decidim/admin/scopes), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.scope_types", scope: "decidim.admin"),
            decidim_admin.scope_types_path,
            position: 5,
            active: [%w(decidim/admin/scope_types), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.areas", scope: "decidim.admin"),
            decidim_admin.areas_path,
            position: 6,
            active: [%w(decidim/admin/areas), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.area_types", scope: "decidim.admin"),
            decidim_admin.area_types_path,
            position: 7,
            active: [%w(decidim/admin/area_types), []],
            if: allowed_to?(:update, :organization, organization: current_organization)

  menu.item I18n.t("menu.help_sections", scope: "decidim.admin"),
            decidim_admin.help_sections_path,
            position: 8,
            active: [%w(decidim/admin/area_types), []],
            if: allowed_to?(:update, :help_sections)
end
