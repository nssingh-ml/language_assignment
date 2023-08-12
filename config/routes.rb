Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "posts#index"
  resources :posts do
    resources :comments, only: [:index, :create]
    resources :likes, only: [:index, :create]
  end

#filter posts only chnages the parameters that passed 
# get 'posts'  (post_id as a parameter.)                #filter posts by author name
# get 'posts'  (params[:date] as a parameter.)          #filter posts by published date
# get 'posts'  (:sort_by= 'likes' as a parameter.)       #filter/sorts posts by likes
# get 'posts'  (:sort_by = 'comments' as a parameter.)   #filter posts by comments

#for top_posts and recommended_posts routes are crated below in level 3



  resources :users, except: [:new, :edit] do
    resources :posts, only: [:index]
    # resources :followers, only: [:index, :create]
    # get 'followers', on: :member
    # get 'my_posts', on: :member
    post 'purchase_subscription', on: :member     #level four
    post 'save_for_later_add', on: :member  #save for later
    get 'show_all_saved', on: :collection
    post 'follows', to: 'followers#create', as: :follow_user
  end
  get '/my_posts', to: 'users#my_posts'
  post '/users/follows', to: 'followers#create', as: :follow_user
  post '/users/unfollows', to: 'followers#delete', as: :unfollow_user
  get '/followers',   to: 'followers#show_all'
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

  # resources :topics, only: [:index]

 # Payments
 post '/payments/create', to: 'payments#create'


 #revision history
 resources :post_revisions, only: [:index, :show]

  #level five
  resources :lists, only: [:create, :index, :show] do
    post 'share', on: :member
    post 'add_post', on: :member   #/lists/:id/add_post  (post_id as a parameter.)
    
  end
  get '/list_posts', to: 'lists#list_posts'   #(list_id as parameter)


  resources :drafts, except: [:edit, :new]
  post 'drafts/:id/publish', to: 'drafts#publish'

  # post 'users/purchase_subscription' to: 'users#purchase_subscription'


end
