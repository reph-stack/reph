defmodule <%= web_namespace %>.Router do
  use <%= web_namespace %>, :router<%= if html do %>

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end<% end %>

  pipeline :api do
    plug :accepts, ["json"]
  end<%= if html do %>

  scope "/", <%= web_namespace %> do
    pipe_through :browser # Use the default browser stack

    get "/", ReactController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", <%= web_namespace %> do
  #   pipe_through :api
  # end<% else %>

  scope "/api", <%= web_namespace %> do
    pipe_through :api
  end<% end %>
end