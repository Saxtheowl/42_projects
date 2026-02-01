Rails.application.routes.draw do
  root "cheatsheet#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
