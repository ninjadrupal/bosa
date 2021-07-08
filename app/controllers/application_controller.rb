class ApplicationController < ActionController::Base

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    sign_out
    flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
    redirect_to '/'
  end

end
