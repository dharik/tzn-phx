defmodule TznWeb.Router do
  use TznWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowEmailConfirmation, PowResetPassword]

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
    plug :load_pods
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :override_current_user_for_impersonation
  end

  pipeline :browser_anonymous do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
    plug :override_current_user_for_impersonation
  end


  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
  end

  scope "/", TznWeb do
    pipe_through [:protected, :browser]
    get "/", EntryController, :launch_app
    get "/school_admin/*route", EntryController, :launch_school_admin_app

    get "/impersonation/stop", Admin.ImpersonationController, :stop

    scope "/mentor", as: :mentor do
      pipe_through [:mentor]

      get "/", Mentor.PodController, :index
      resources "/pods", Mentor.PodController
      resources "/mentees", Mentor.MenteeController
      resources "/timesheet_entries", Mentor.TimesheetEntryController, except: [:show]
      get "/timeline", Mentor.TimelineController, :index
      get "/timeline/:pod_id", Mentor.TimelineController, :index

      resources "/timeline_event_markings", Mentor.TimelineEventMarkingController,
        only: [:new, :edit, :create, :update]

      resources "/college_lists", Mentor.CollegeListController,
        only: [:index, :show, :edit, :update, :create]

      resources "/ecvo_lists", Mentor.ECVOListController, only: [:index, :show, :edit, :update, :create]

      resources "/scholarship_lists", Mentor.ScholarshipListController,
        only: [:index, :show, :edit, :update, :create]

      get "/help", Mentor.HelpController, :show
    end

    scope "/admin", as: :admin do
      pipe_through [:admin]

      get "/", Admin.MentorController, :index
      get "/matching", Admin.MatchingAlgorithmController, :show
      get "/impersonation/start", Admin.ImpersonationController, :start
      get "/cmt_dashboard", Admin.CmtDashboardController, :show
      resources "/users", Admin.UserController
      resources "/mentees", Admin.MenteeController
      resources "/pods", Admin.PodController, except: [:index]
      resources "/pod_flags", Admin.PodFlagController, only: [:edit, :update, :index]
      resources "/pod_todos", Admin.PodTodoController, only: [:new, :create, :edit, :update]
      resources "/mentors", Admin.MentorController
      get "/mentor_payments", Admin.MentorPaymentsController, :index
      resources "/strategy_sessions", Admin.StrategySessionController

      resources "/timesheet_entries", Admin.TimesheetEntryController,
        only: [:edit, :update, :delete]

      resources "/contract_purchases", Admin.ContractPurchaseController

      patch "/questions/move_up", Admin.QuestionSetController, :move_up, as: :move_question_up

      patch "/questions/move_down", Admin.QuestionSetController, :move_down,
        as: :move_question_down

      resources "/questions", Admin.QuestionController
      resources "/question_sets", Admin.QuestionSetController, only: [:edit, :update]
      resources "/questionnaires", Admin.QuestionnaireController, only: [:edit, :update]
      resources "/calendars", Admin.CalendarController
      resources "/calendar_events", Admin.CalendarEventController, except: [:index]
      resources "/pod_groups", Admin.PodGroupController
      resources "/school_admins", Admin.SchoolAdminController
    end

    scope "/", as: :parent do
      get "/dashboard", Parent.DashboardController, :show
      get "/todo", Parent.TodoController, :update
      get "/work_log", Parent.WorklogController, :show
      get "/refer", Parent.ReferralController, :show
      get "/additional_offerings", Parent.AdditionalOfferingsController, :show
      post "/refer", Parent.ReferralController, :create
      get "/timeline", Parent.TimelineController, :show
      # get "/resources", Parent.LibraryController, :show
    end
  end

  scope "/", TznWeb do
    pipe_through [:browser_anonymous]

    get "/college_list/:access_key_short", Parent.CollegeListController, :edit
    get "/ecvo_list/:access_key_short", Parent.ECVOListController, :edit
    get "/scholarship_list/:access_key_short", Parent.ScholarshipListController, :edit

    post "/research_list/:access_key_short",
         Parent.QuestionnaireController,
         :create_or_update_answer

    put "/research_list/:access_key_short", Parent.QuestionnaireController, :upload
  end

  scope "/", TznWeb do
    pipe_through [:browser_anonymous, :protect_from_forgery]

    get "/organizeu/:access_key", TimelinesController, :show
    get "/organizeu", TimelinesController, :show
  end

  scope "/", TznWeb do
    get "/organizeu/ical/:access_key", TimelinesController, :ical
    get "/organizeu/google_calendar/:access_key", TimelinesController, :google_calendar
    get "/organizeu/apple_calendar/:access_key", TimelinesController, :apple_calendar

    post "/typeform/", TypeformWebhookController, :handle
  end

  scope "/admin/api", TznWeb do
    pipe_through [:admin]
    get "/mentors", Admin.MentorController, :index_json
    post "/answers", Admin.AnswerController, :create_or_update
  end

  scope "/mentor/api", TznWeb do
    pipe_through [:api, :mentor]

    post "/answers", Mentor.AnswerController, :create_or_update
  end

  scope "/api", TznWeb do
    pipe_through [:api]

    get "/school_admin", SchoolAdmin.ApiController, :handle
    post "/school_admin", SchoolAdmin.ApiController, :handle
  end

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
      live_dashboard "/LiveDashboard", metrics: TznWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
