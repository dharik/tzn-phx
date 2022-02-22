defmodule Tzn.Emails do
  alias Tzn.Repo
  alias Tzn.Emails.EmailHistory
  import Ecto.Query

  def last_email_sent_at(address) do
    Repo.one(
      from(e in EmailHistory,
        where: e.email_address == ^address,
        limit: 1,
        select: max(e.sent_at)
      )
    )
  end

  def last_email_sent_at(address, key) do
    Repo.one(
      from(e in EmailHistory,
        where: e.email_address == ^address and e.key == ^key,
        limit: 1,
        select: max(e.sent_at)
      )
    )
  end

  def append_email_history(email_address, key) do
    %EmailHistory{}
    |> EmailHistory.changeset(%{
      email_address: email_address,
      key: key,
      sent_at: Timex.now()
    })
    |> Repo.insert()
  end
end
