Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "posts#index"
  resources :posts do
    resources :comments, only: [:index, :create]
    resources :likes, only: [:index, :create]
  end

  resources :users, except: [:new, :edit] do
    resources :posts, only: [:index]
    # resources :followers
    # get 'followers', on: :member
    get 'my_posts', on: :member
    post 'purchase_subscription', on: :member
  end

  resources :topics, except: [:new, :edit]

  resources :comments, except: [:new, :edit, :index, :create]
  resources :likes, except: [:new, :edit, :index, :create]

  # Add custom routes for user authentication
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'


  # Level 3 features
  get '/top_posts', to: 'posts#top_posts'
  get '/recommended_posts', to: 'recommendations#recommended_posts'
  get '/more_posts_by_author/:id', to: 'posts#more_posts_by_author', as: :more_posts_by_author
  resources :topics, only: [:index]


  # post 'users/purchase_subscription' to: 'users#purchase_subscription'


end
