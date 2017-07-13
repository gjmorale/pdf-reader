Rails.application.routes.draw do
  resources :dictionary_elements
  resources :dictionaries
  get 'file_manager/update'

  get 'file_manager/new'

  get 'file_manager/index'

  get 'static_pages/test'

  resources :statements do 
    collection do
      post :all, constraints: StatementsCommit.new(StatementsCommit::RELOAD), action: :reload_statements, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::AUTO), action: :auto_statements, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::INDEX), action: :index_statements, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::INDEXED), action: :fit_statements, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::READ), action: :read_statements, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::ASSIGN), action: :assign, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::UNASSIGN), action: :unassign, controller: :handlers
      post :all, constraints: StatementsCommit.new(StatementsCommit::UPDATE), action: :update_statements, controller: :handlers
    end
  end
  resources :handlers do 
    member do
      post :edit, constraints: StatementsCommit.new(StatementsCommit::RELOAD), action: :reload_statements
      post :edit, constraints: StatementsCommit.new(StatementsCommit::AUTO), action: :auto_statements
      post :edit, constraints: StatementsCommit.new(StatementsCommit::INDEX), action: :index_statements
      post :edit, constraints: StatementsCommit.new(StatementsCommit::INDEXED), action: :fit_statements
      post :edit, constraints: StatementsCommit.new(StatementsCommit::READ), action: :read_statements
      post :edit, constraints: StatementsCommit.new(StatementsCommit::ASSIGN), action: :assign
      post :edit, constraints: StatementsCommit.new(StatementsCommit::UNASSIGN), action: :unassign
      post :edit, constraints: StatementsCommit.new(StatementsCommit::UPDATE), action: :update_statements
    end
  end
  resources :sequences
  resources :taxes do
    member do
      get :times, action: :time_nodes
    end
  end
  resources :societies do 
    collection do
      post :filter, action: :filter
    end
    member do
      get :times, action: :time_nodes
      get :ifs, action: :if_nodes
      get :statements, action: :statement_nodes
    end
  end
  resources :banks
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
