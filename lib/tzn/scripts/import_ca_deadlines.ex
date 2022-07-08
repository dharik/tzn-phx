defmodule Tzn.Scripts.ImportCaDeadlines do
  def run do
    {:ok, f} = File.read("ca_scraper/common_app_colleges.json")
    colleges = Jason.decode!(f)

    Enum.each(colleges, fn c ->
      name = c["name"]
      calendar = get_or_create_calendar(name) |> Tzn.Repo.preload(:events)

      early_decision = parse_date(c["ed"])

      get_or_create_deadline(
        calendar,
        early_decision,
        "Early Decision",
        "Early Decision Description",
        c
      )

      early_decision2 = parse_date(c["ed2"])

      get_or_create_deadline(
        calendar,
        early_decision2,
        "Early Decision 2",
        "Early Decision 2 Description",
        c
      )

      early_action = parse_date(c["ea"])

      get_or_create_deadline(
        calendar,
        early_action,
        "Early Action",
        "Early Action",
        c
      )

      early_action2 = parse_date(c["ea2"])

      get_or_create_deadline(
        calendar,
        early_action2,
        "Early Action 2",
        "Early Action 2 Description",
        c
      )

      restricted_early_action = parse_date(c["rea"])

      get_or_create_deadline(
        calendar,
        restricted_early_action,
        "Restricted Early Action",
        "Restricted Early Action Description",
        c
      )

      rolling = parse_date(c["rd"])

      get_or_create_deadline(
        calendar,
        rolling,
        "Rolling Deadline",
        "Rolling Deadline Description",
        c
      )
    end)
  end

  def get_or_create_deadline(_calendar, nil, _name, _description, _import_data) do
    nil
  end

  def get_or_create_deadline(calendar, date, name, description, import_data) do
    existing_event = Enum.find(calendar.events, nil, fn e -> e.name == name end)

    if existing_event do
      {:ok, event} = Tzn.Timelines.update_event(existing_event, %{
        description: description,
        import_data: import_data,
        month: date.month,
        day: date.day
      })

      event
    else
      {:ok, event} =
        Tzn.Timelines.create_event(%{
          calendar_id: calendar.id,
          name: name,
          description: description,
          month: date.month,
          day: date.day,
          grade: "senior",
          import_data: import_data
        })

      event
    end
  end

  def get_or_create_calendar(name) do
    calendar = Tzn.Timelines.get_calendar_by_name(name)

    if is_nil(calendar) do
      {:ok, calendar} =
        Tzn.Timelines.create_calendar(%{name: name, searchable: true, type: "college_cyclic", subscribed_by_default: false})

      calendar
    else
      calendar
    end
  end

  def parse_date("") do
    nil
  end

  def parse_date(nil) do
    nil
  end

  def parse_date(str) do
    {:ok, date} = Timex.parse(str, "{ISO:Extended}")
    date
  end
end

"""
%{
  "cngReq" => false,
  "cr" => false,
  "ea" => nil,
  "ea2" => nil,
  "ed" => nil,
  "ed2" => nil,
  "fyInternationalTestURL" => "",
  "intlFee" => 50,
  "intlTest" => "See website",
  "memberId" => 715,
  "memberType" => "Coed",
  "mr" => true,
  "name" => "Zaytuna College",
  "oe" => 0,
  "peReq" => false,
  "portfolio" => 0,
  "rd" => "2022-04-15T04:00:00",
  "rea" => nil,
  "satactTests" => "See website",
  "savesForms" => true,
  "sortName" => "zaytuna college",
  "te" => 3,
  "testPolicyUrl" => "https://zaytuna.edu/admissions/how-to-apply",
  "testReqd" => "Never required",
  "type" => 1,
  "usFee" => 50,
  "wsReqd" => 0
}
"""
