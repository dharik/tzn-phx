defmodule Tzn.GradeYearConversions do

  @doc """
  deprecated
  """
  def calculate_event_year(event, grad_year) do
    if event.month >= 9 do
      # After september means it's fall so push it back an extra year
      grad_year - grade_to_offset(event.grade) - 1
    else
      grad_year - grade_to_offset(event.grade)
    end
  end

  def grade_to_offset(grade) do
    case grade do
      "freshman" -> 3
      :freshman -> 3
      "sophomore" -> 2
      :sophomore -> 2
      "junior" -> 1
      :junior -> 1
      "senior" -> 0
      :senior -> 0
    end
  end

  def graduation_year(current_grade) do
    graduation_year(current_grade, Timex.now().month, Timex.now().year)
  end

  def graduation_year(current_grade, current_month, current_year) do
    cond do
      current_month >= 9 && current_grade == "freshman" -> current_year + 4
      current_grade == "freshman" -> current_year + 3
      current_month >= 9 && current_grade == "sophomore" -> current_year + 3
      current_grade == "sophomore" -> current_year + 2
      current_month >= 9 && current_grade == "junior" -> current_year + 2
      current_grade == "junior" -> current_year + 1
      current_month >= 9 && current_grade == "senior" -> current_year + 1
      current_grade == "senior" -> current_year
      true -> Timex.now().year - 1
    end
  end

  def event_year(graduation_year, event_grade, event_month) do
    if event_month >= 9 do
      case event_grade do
        "freshman" -> graduation_year - 4
        "sophomore" -> graduation_year - 3
        "junior" -> graduation_year - 2
        "senior" -> graduation_year - 1
      end
    else
      case event_grade do
        "freshman" -> graduation_year - 3
        "sophomore" -> graduation_year - 2
        "junior" -> graduation_year - 1
        "senior" -> graduation_year - 0
      end
    end
  end
end
