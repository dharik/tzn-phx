defmodule TznWeb.Router do
  use TznWeb, :router
  use Pow.Phoenix.Router

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

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

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", TznWeb do

    get "/", MenteeController, :index

    # /admin/contract_purchases/new?mentee_id=#

    scope "/mentor", as: :mentor do
      pipe_through [:browser, :protected]


      get "/", Mentor.MenteeController, :index
      resources "/mentees", Mentor.MenteeController
      resources "/timesheet_entries", Mentor.TimesheetEntryController, except: [:show]
      resources "/strategy_sessions", Mentor.StrategySessionController
      get "/timeline", Mentor.TimelineController, :index
      post "/timeline", Mentor.TimelineController, :update_or_create
      get "/help", Mentor.HelpController, :show
    end


    scope "/admin", as: :admin do
      pipe_through [:browser, :protected]

      get "/", Admin.UserController, :index
      resources "/users", Admin.UserController
      resources "/mentees", Admin.MenteeController
      resources "/mentors", Admin.MentorController
      resources "/strategy_sessions", Admin.StrategySessionController
      resources "/timesheet_entries", Admin.TimesheetEntryController, only: [:edit, :update, :delete]
    end
  end



  # Other scopes may use custom stacks.
  # scope "/api", TznWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TznWeb.Telemetry
    end
  end
end
