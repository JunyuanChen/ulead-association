Rails.application.routes.draw do
  get 'users/sign_in', to: 'users#sign_in', as: :sign_in
  post 'users/sign_in', to: 'users#do_sign_in', as: :do_sign_in
  delete 'users/sign_out', to: 'users#do_sign_out', as: :do_sign_out
  patch 'users/:id/update_password', to: 'users#update_password', as: :update_password
  patch 'users/:id/update_permission', to: 'users#update_permission', as: :update_permission
  resources :users, only: %i[index new create show edit destroy]

  get 'articles/:id/edit_tags', to: 'articles#edit_tags', as: :edit_tags
  post 'articles/:id/edit_tags', to: 'articles#query_tags', as: :query_tags
  patch 'articles/:id/approve', to: 'articles#approve', as: :approve_article
  patch 'articles/:id/hide', to: 'articles#hide', as: :hide_article
  resources :articles

  patch 'tags/:id/add_article', to: 'tags#add_article', as: :add_tag
  delete 'tags/:id/remove_article', to: 'tags#remove_article', as: :remove_tag
  resources :tags

  get 'resources', to: 'resources#index', as: :resources
  post 'resources/upload', to: 'resources#upload'
  get 'resources/:digest', to: 'resources#show', as: :show_resource, constraints: { digest: /[A-Fa-f0-9]{64}/ }
  delete 'resources/:digest', to: 'resources#destroy', as: :destroy_resource, constraints: { digest: /[A-Fa-f0-9]{64}/ }

  resources :dynamic_routes, path: 'routes', only: %i[index create destroy]
  get 'routes/blackholes/syslog', to: 'blackholes#syslog', as: :syslog
  get 'routes/blackholes/systop', to: 'blackholes#systop', as: :systop
  resources :blackholes, path: 'routes/blackholes', only: %i[index create destroy]

  constraints ->(req) { req.session[:user_id] == 1 } do
    mount RVT::Engine, at: '/routes/blackholes/sysshell'
  end

  get '(*path)', to: 'dynamic_routes#display', defaults: { path: '' }
end
