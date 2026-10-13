Rails.application.routes.draw do
  get "/health", to: proc { |_env|
    [200, { "content-type" => "application/json" }, ['{"status":"ok"}']]
  }
  post "/api/analyze", to: "api/v1/devotionals#create"
  namespace :api do
    namespace :v1 do
      resources :devotionals, only: :create
    end
  end
end
