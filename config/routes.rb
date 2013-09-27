Showgap::Application.routes.draw do

  match '/auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  match '/auth/failure', to: 'main#login_failure'

  scope 'api', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' } do
    resources :users, only: :show

    restful_routes = [:index, :show, :create, :update, :destroy]

    resources :episodes, only: restful_routes do
      resources :discussions, only: restful_routes do
        resources :replies, only: restful_routes do
          post 'vote'
        end
      end
    end

  end

  root to: "main#index"
end
