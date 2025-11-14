# frozen_string_literal: true

McpInspector::Web::Engine.routes.draw do
  root to: "dashboard#index"

  resources :servers, only: [:index] do
    member do
      get :info
      get :tools
      get :prompts
      get :resources
    end
  end

  resources :operations, only: [] do
    collection do
      post :execute_tool
      post :read_resource
      post :get_prompt
    end
  end
end
