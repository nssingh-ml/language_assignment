Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "posts#index"

  # Add custom routes for user authentication
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # resources :posts do
  #   resources :comments, only: [:index, :create]
  #   resources :likes, only: [:index, :create]
  #   resources :post_revisions, only: [:index, :show, :create]  
  # end
  #filter posts only chnages the parameters that passed 
# get '/posts'  (params[:user_id] as a parameter.)                #filter posts by author name
# get '/posts'  (params[:date] as a parameter.)          #filter posts by published date
# get '/posts'  (:sort_by= 'likes' as a parameter.)       #filter/sorts posts by likes
# get '/posts'  (:sort_by = 'comments' as a parameter.)   #filter posts by comments

# we canuse the above routes for posts using the resources that handle curd operations but it creates some 
# conflicts in some cases so we create independetd routs for controller wehre needed


# independents routes for posts controller
  get '/posts', to: 'posts#index'
  get '/posts/filter/user/:user_id', to: 'posts#index'      #filter posts by author name
  get '/posts/filter/date/:date', to: 'posts#index'         #filter posts by published date
  get '/posts/sort/:sort_by', to: 'posts#index'               # (params[:sort_by]= 'likes' for likes,params[:sort_by] = 'comments for comments )
  # get '/posts/sort/comments', to: 'posts#index'           # (/posts/sort/likes  :to sort by likes,/posts/sort/comments  :to sort by comments count) 
  get '/posts/:id', to: 'posts#show'
  post '/posts/create', to: 'post#create'
  put  '/posts/update/:id', to: 'post#update'
  delete '/posts/delete/:id', to: 'posts#destroy'
  get '/posts/search', to: 'posts#search'
#share post
  post '/posts/share/:post_id', to: 'posts#share_post'     #parameters(:message,:recipient_email also need to passed)
  # Level 3 features
  get '/my_posts', to: 'posts#my_posts'
  get '/top_posts', to: 'posts#top_posts'
  get '/recommended_posts', to: 'posts#recommended_posts'
  get '/more_posts_by_author/:id', to: 'posts#more_posts_by_author', as: :more_posts_by_author  #:id is post id


  #users controller
  # resources :users, except: [:new, :edit] do
  #   resources :posts, only: [:index]
  #   # resources :followers, only: [:index, :create]
  #   # get 'followers', on: :member
  #   # get 'my_posts', on: :member
  #   post 'purchase_subscription', on: :member     #level four
  #   post 'save_for_later_add', on: :member  #save for later
  #   get 'show_all_saved', on: :collection
  #   post 'follows', to: 'followers#create', as: :follow_user
  # end

  #independent routes for users controller
  post '/users/signup', to: 'users#create'
  get '/users/showall', to: 'users#all_users'
  get '/users/search', to: 'users#search_user'
  delete '/users/delete/:id', to: 'users#destroy'
  put '/users/update', to: 'users#update'                     #also pass password parameter for authentication with others param
  get '/users/details/:id', to: 'users#show'
  post '/users/saveForLater/:post_id', to:'users#save_for_later'
  get '/users/savedPosts', to: 'users#show_all_saved'
  get '/users/my_details', to: 'users#my_details'
  get 'users/my_subscription', to: 'users#my_subscription'    #subcription of current user
  

  #follower
  post '/users/follows', to: 'followers#create', as: :follow_user
  post '/users/unfollows', to: 'followers#delete', as: :unfollow_user
  get '/users/followers',   to: 'followers#show_all'

#topics
  # resources :topics, except: [:new, :edit]
  post '/topic/create', to: 'topics#create'
  get '/topic/showAll', to: 'topics#show_all_topics'
  put '/topic/update/:id', to: 'topics#update'
  delete '/topic/delete/:id', to: 'topics#delete'   #:id is topic id  (but topic delet is not needed in most cases)


#likes
  # resources :likes, except: [:new, :edit, :index, :create]
  delete '/like/remove/:post_id', to: 'likes#remove_like'
  post '/like/create/:post_id', to: 'likes#create'
  get '/like/totalLikes/:post_id', to: 'likes#total_likes_on_a_post'
  get 'likes/post/:id', to: 'likes#show'   #:id is post_id
  
# comments
  # resources :comments, except: [:new, :edit, :index, :create]
  post '/comment/create', to: 'comments#create'
  delete '/comment/delete/:comment_id', to: 'comments#delete'
  get '/comment/all/:post_id', to: 'comments#show'
   

 # Payments
 post '/payments/create', to: 'payments#create'   #:amount as parameter
 get '/payments/payment_test', to: 'payments#payment_test'


 #revision history
  resources :post_revisions, only: [:index, :show, :create]
  get 'revision_history/post/:post_id', to: 'post_revisions#index'
  # to revert the Post to its previous version.'
  get 'revision_history/revert_post/:post_id/:revision_id', to: 'post_revisions#revert_to_previous_postversion'

  #level five
  #lists
  resources :lists, only: [:create, :index, :show] do
    post 'share', on: :member       #to share list through mail(:id -list_id and :recipient_email-email parameter of recipient)
    post 'add_post', on: :member   #/lists/:id/add_post  (:post_id as a parameter, and :id is list id)
    
  end
  get '/list_posts', to: 'lists#list_posts'   #(list_id as parameter)

  #drafts
  # resources :drafts, except: [:edit, :new]      #if any issue/error then uncoment this resources
  post '/draft/create', to: 'drafts#create'
  put '/draft/update/:id', to: 'drafts#update'    #:id id draft id
  post '/draft/:id/publish', to: 'drafts#publish'    #publish the draft
  get '/draft/all', to: 'drafts#show_all'             # all the draft of cuurent user



end
