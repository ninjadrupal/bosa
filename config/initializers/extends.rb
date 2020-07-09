
require "extends/decidim-core/lib/decidim/view_model"
require "extends/decidim-core/app/uploaders/decidim/attachment_uploader"
require "extends/decidim-core/app/models/decidim/user"
require "extends/decidim-core/app/cells/decidim/progress_bar_cell"

require "extends/decidim-initiatives/app/helpers/decidim/initiatives/application_helper"
require "extends/decidim-initiatives/app/helpers/decidim/initiatives/initiative_helper"
require "extends/decidim-initiatives/app/cells/decidim/initiatives/initiative_m_cell"
require "extends/decidim-initiatives/app/permissions/decidim/initiatives/admin/permissions"
require "extends/decidim-initiatives/app/forms/decidim/initiatives/admin/initiative_type_form"
require "extends/decidim-initiatives/app/forms/decidim/initiatives/admin/initiative_form"
require "extends/decidim-initiatives/app/commands/decidim/initiatives/admin/create_initiative_type"
require "extends/decidim-initiatives/app/commands/decidim/initiatives/admin/update_initiative_type"


# require 'extends/confirmations_controller_extend'
require "extends/initiative_model_extend"
require "extends/account_form_extend"
require "extends/initiative_admin_form_extend"
require "extends/organization_appearance_form_extend"
require "extends/update_organization_appearance_extend"
require "extends/destroy_account_extend"
