# Clear menu items to reorder
Decidim::MenuRegistry.destroy(:menu)

Decidim.menu :menu do |menu|

  menu.item I18n.t("menu.home", scope: "decidim"),
            decidim.root_path,
            position: 1,
            active: :exclusive

  if current_organization.bosa_cities_app_type?
    menu.item I18n.t("menu.processes", scope: "decidim"),
              decidim_participatory_processes.participatory_processes_path,
              position: 2,
              if: Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?,
              active: :exclusive
    Decidim::NavbarLinks::NavbarLink.organization(current_organization).each do |navbar_link|
      menu.item translated_attribute(navbar_link.title),
                navbar_link.link,
                position: 3,
                active: :inclusive
    end
    menu.item I18n.t("menu.assemblies", scope: "decidim"),
              decidim_assemblies.assemblies_path,
              position: 4,
              if: Decidim::Assembly.where(organization: current_organization).published.any?,
              active: :inclusive
    menu.item I18n.t("menu.help", scope: "decidim"),
              decidim.pages_path,
              position: 5,
              active: :inclusive
  else
    menu.item I18n.t("menu.suggestions", scope: "decidim"),
              decidim_suggestions.suggestions_path,
              position: 2,
              if: current_organization.module_suggestions_enabled? && Decidim::SuggestionsType.where(organization: current_organization).any?,
              active: :inclusive
    menu.item I18n.t("menu.assemblies", scope: "decidim"),
              decidim_assemblies.assemblies_path,
              position: 3,
              if: Decidim::Assembly.where(organization: current_organization).published.any?,
              active: :inclusive
    menu.item I18n.t("menu.initiatives", scope: "decidim"),
              decidim_initiatives.initiatives_path,
              position: 4,
              if: current_organization.module_initiatives_enabled? && Decidim::InitiativesType.where(organization: current_organization).any?,
              active: :inclusive
    menu.item I18n.t("menu.help", scope: "decidim"),
              decidim.pages_path,
              position: 5,
              active: :inclusive
  end
end
