defmodule HexviewWeb.Router do
  use HexviewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HexviewWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/packages/:name", PackageController, :show
    get "/packages/:name/tree", PackageController, :show
    get "/packages/:name/tree/*path", PackageController, :tree
    get "/packages/:name/blob/*path", PackageController, :blob
  end

  # Other scopes may use custom stacks.
  # scope "/api", HexviewWeb do
  #   pipe_through :api
  # end
end
