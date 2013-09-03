require 'sidekiq/web'

Catarse::Application.routes.draw do

  devise_for :users, path: '',
    path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
    controllers:  { omniauth_callbacks: :omniauth_callbacks, passwords: :passwords }


  devise_scope :user do
    post '/sign_up', to: 'devise/registrations#create', as: :sign_up
  end


  get '/thank_you' => "static#thank_you"


  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarseCreditCardNet::Engine => "/", as: :catarse_credit_card_net
  mount CatarseEcheckNet::Engine => "/", as: :catarse_echeck_net
  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  #mount CatarseMoip::Engine => "/", as: :catarse_moip

  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index ]
  end

  # Channels
  constraints subdomain: 'asas' do
    namespace :channels, path: '' do
      namespace :adm do
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
          end
        end
      end
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
        end
      end
      resources :channels_subscribers, only: [:index, :create, :destroy]
    end
  end

  # Root path should be after channel constraints
  root to: 'projects#index'

  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get '/how-it-works',          to: 'static#how_it_works',        as: :how_it_works
  get "/about",                 to: "static#about",               as: :about
  get "/faq",                   to: "static#faq",                 as: :faq
  get "/terms",                 to: "static#terms",               as: :terms
  get "/privacy",               to: "static#privacy",             as: :privacy

  # TEMP
  get "/guidelines_tips",       to: "static#guidelines_tips",     as: :guidelines_tips
  get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/guidelines_start",      to: "static#guidelines_start",    as: :guidelines_start

  get "/explore" => "explore#index", as: :explore
  get "/explore#:quick" => "explore#index", as: :explore_quick

  get "/reward/:id" => "rewards#show", as: :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  resources :projects do
    resources :project_faqs, controller: 'projects/project_faqs', only: [ :index, :create, :destroy ]
    resources :project_documents, controller: 'projects/project_documents', only: [ :index, :create, :destroy ]
    resources :updates, controller: 'projects/updates', only: [ :index, :create, :destroy ]
    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end
    resources :backers, controller: 'projects/backers', only: [ :index, :show, :new, :create ] do
      member do
        get 'credits_checkout'
        post 'update_info'
      end
    end
    collection do
      get 'video'
    end
    member do
      post :send_reward_email
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'embed_panel'
    end
  end
  resources :users do
    resources :projects, controller: 'users/projects', only: [ :index ]
    collection do
      get :uservoice_gadget
    end
    resources :backers, controller: 'users/backers', only: [:index] do
      member do
        get :request_refund
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end
  # match "/users/:id/request_refund/:back_id" => 'users#request_refund'

  resources :credits, only: [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end

  namespace :adm do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_soon'
      end
    end

    resources :press_assets
    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  get "/set_email" => "users#set_email", as: :set_email_users
  get "/:permalink" => "projects#show", as: :project_by_slug

end
