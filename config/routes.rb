# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  get "/healthcheck", to: "healthcheck#show"
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_scope :user do
    get '/admin_sign_in', to: "decidim/devise/sessions#new"
    post "omniauth_registrations" => "decidim/devise/omniauth_registrations#create"
    match "users/auth/:provider/logout",
          to: "devise/omniauth_registrations#logout",
          as: :user_omniauth_logout,
          via: [:get, :post, :delete]
  end

  # authenticate(:user) do
  #   resources :conversations, to: redirect('/404')
  #   resources :notifications, to: redirect('/404')
  #   resource :user_interests, to: redirect('/404')
  # end

  # resources :profiles, only: [:show], param: :nickname, to: redirect('/404')
  # scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^\/]+} } do
  #   get "following", to: redirect('/404')
  #   get "followers", to: redirect('/404')
  #   get "badges", to: redirect('/404')
  #   get "groups", to: redirect('/404')
  #   get "members", to: redirect('/404')
  #   get "activity", to: redirect('/404')
  #   get "timeline", to: redirect('/404')
  # end

  # get "/search", to: redirect('/404')

  Decidim::Api::Engine.routes.draw do
    post "/translate", to: "translation#translate"
    post "/" => "queries#create", as: :root

    unless Rails.env.production?
      get "/graphiql", to: "graphiql#show", graphql_path: "/api", as: :graphiql
      # mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api", as: :graphiql
      get "/docs", to: "documentation#show", as: :documentation
      get "/", to: redirect("/api/docs")
    end
  end

  mount Decidim::Core::Engine => '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
