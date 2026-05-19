Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "shorturls#index"

  resources :shorturls, only: [ :new, :create, :show ]



  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Shorturl redirection. This should be the last in order to prevent
  # resolving to this routes for non-shorturls
  get "/:code", to: "shorturls#redirect_shorturl", as: :redirect_shorturl, constraints: { code: /[0-9A-Za-z]{1,15}/ }
end
