Rails.application.routes.draw do
  devise_for :users
  resources :users

  get "file_manager/index"
  get "file_manager/new"
  post "file_manager/files", constraints: FileManagerCommits.new(FileManagerCommits::OPEN), action: :open, controller: :file_manager
  get "file_manager/learn"

  get 'static_pages/test'
  get 'static_pages/guide'
  get 'static_pages/activity'

  root 'static_pages#home'

  resources :statements do 
    collection do
      post :filter, action: :filter
      post :reload
      post :batch_update, constraints: StatementsCommit.new(StatementsCommit::BATCH_UPDATE), action: :batch_update
      post :batch_update, constraints: StatementsCommit.new(StatementsCommit::UPGRADE), action: :upgrade
      post :batch_update, constraints: StatementsCommit.new(StatementsCommit::DOWNGRADE), action: :downgrade
  end
    member do
      get :open
      get :assign
      get :unassign
    end
  end
  resources :handlers do 
  end
  resources :sequences do
    collection do
      post :filter
    end
  end
  resources :taxes do
    member do
      get :progress
      get :times, action: :time_nodes
      get :adjust
      get :close
    end
  end
  resources :societies do 
    member do
      get :times, action: :time_nodes
      get :ifs, action: :if_nodes
      get :statements, action: :statement_nodes
      get :progress
    end
    collection do
      post :reload
      get :progress
    end
  end
  resources :banks do 
    member do
      get :progress
    end
    collection do
      get :progress
    end
  end
  resources :synonyms
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
