defmodule Tzn.Policy do
  alias Tzn.Policy.UnauthorizedError
  alias Tzn.Users.User

  def assert_admin(%User{} = u) do
    unless Tzn.Users.admin?(u) do
      raise UnauthorizedError
    end
  end

  def assert_admin_or_college_list_specialist(%User{} = u) do
    unless Tzn.Transizion.college_list_speciality?(u) || Tzn.Users.admin?(u) do
      raise UnauthorizedError
    end
  end

  def assert_admin_or_mentor(%User{} = u) do
    unless Tzn.Transizion.mentor?(u) || Tzn.Users.admin?(u) do
      raise UnauthorizedError
    end
  end


end
