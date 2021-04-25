defmodule TznWeb.Router do
  use TznWeb, :router
  use Pow.Phoenix.Router
  use Plugsnag
  
  import TznWeb.AdminPlugs
  import TznWeb.MentorPlugs

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug :put_layout, {TznWeb.LayoutView, :admin}
    plug :load_admin_profile
    plug :ensure_admin_profile
  end
  
  pipeline :mentor do
    plug :put_layout, {TznWeb.LayoutView, :mentor}
    plug :load_mentor_profile
    plug :ensure_mentor_profile
    plug :load_my_mentees
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
    pipe_through [:protected, :browser]
    get "/", EntryController, :launch_app

    scope "/mentor", as: :mentor do
      pipe_through [:mentor]

      get "/", Mentor.MenteeController, :index
      resources "/mentees", Mentor.MenteeController
      resources "/timesheet_entries", Mentor.TimesheetEntryController, except: [:show]
      resources "/strategy_sessions", Mentor.StrategySessionController, except: [:show, :index]
      get "/timeline", Mentor.TimelineController, :index
      get "/timeline/:mentee_id", Mentor.TimelineController, :index

      resources "/timeline_event_markings", Mentor.TimelineEventMarkingController, only: [:new, :edit, :create, :update]

      get "/help", Mentor.HelpController, :show
    end

    scope "/admin", as: :admin do
      pipe_through [:admin]
      
      get "/", Admin.MentorController, :index
      get "/matching", Admin.MatchingAlgorithmController, :show
      resources "/users", Admin.UserController
      resources "/mentees", Admin.MenteeController
      resources "/mentors", Admin.MentorController
      resources "/strategy_sessions", Admin.StrategySessionController
      resources "/timesheet_entries", Admin.TimesheetEntryController, only: [:edit, :update, :delete]
      resources "/contract_purchases", Admin.ContractPurchaseController
      resources "/mentor_timeline_events", Admin.MentorTimelineEventController
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
