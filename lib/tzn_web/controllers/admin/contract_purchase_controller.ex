defmodule TznWeb.Admin.ContractPurchaseController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Repo
  alias Tzn.Transizion.ContractPurchase

  plug :load_mentee_list

  def load_mentee_list(conn, _) do
    mentees = Tzn.Mentee.list_mentees()
    conn |> assign(:mentees, mentees)
  end

  def new(conn, params) do
    changeset = Transizion.change_contract_purchase(%ContractPurchase{
      date:  Timex.now() |> Timex.shift(hours: -5) |> Timex.to_naive_datetime,
      hours: 5.0
    }, params)
    render(conn, "new.html", changeset: changeset)
  end

  def delete(conn, %{"id" => id}) do
    contract_purchase = Transizion.get_contract_purchase!(id) |> Repo.preload(:mentee)
    {:ok, _contract_purchase} = Transizion.delete_contract_purchase(contract_purchase)

    conn
    |> put_flash(:info, "Contract Purchase deleted successfully.")
    |> redirect(to: Routes.admin_mentee_path(conn, :show, contract_purchase.mentee))
  end

  def create(conn, %{"contract_purchase" => contract_purchase_params}) do
    case Transizion.create_contract_purchase(contract_purchase_params) do
      {:ok, contract_purchase} ->
        conn
        |> put_flash(:info, "Contract hours added successfully.")
        |> redirect(to: Routes.admin_mentee_path(conn, :show, contract_purchase.mentee_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end
