Rails.application.routes.draw do
  root "imports#new"

  # Upload step
  resources :imports, only: [:new, :create]

  # Preview + confirm step
  resources :import_sessions, only: [:show] do
    member do
      delete "rows/:row_index", to: "import_sessions#dismiss_row", as: :dismiss_row
      post :confirm
    end
  end

  # Committed records
  resources :properties, only: [:index, :show]
end
