Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'weather_finder#index'

  namespace :authentication, path: '', as: '' do
    resources :users, only: %i[new create], path: 'register', path_names: { new: '/' }
    resources :sessions, only: %i[new create destroy], path: 'login', path_names: { new: '/' }
  end

  resources :weather_finder, only: %i[index], path: '/weather_finder'
end
