defmodule TznWeb.Admin.ContractPurchaseController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.ContractPurchase

  def new(conn, params = %{"pod_id" => pod_id}) do
    pod = Tzn.Pods.get_pod!(pod_id)
    changeset = Transizion.change_contract_purchase(%ContractPurchase{
      date:  Timex.now() |> Timex.shift(hours: -5) |> Timex.to_naive_datetime,
      hours: 5.0
    }, params)
    render(conn, "new.html", changeset: changeset, pod: pod)
  end

  def delete(conn, %{"id" => id}) do
    contract_purchase = Transizion.get_contract_purchase!(id)
    {:ok, _contract_purchase} = Transizion.delete_contract_purchase(contract_purchase)

    conn
    |> redirect(to: Routes.admin_pod_path(conn, :show, contract_purchase.pod_id))
  end

  def create(conn, %{"contract_purchase" => contract_purchase_params}) do
    pod = Tzn.Pods.get_pod!(contract_purchase_params["pod_id"])

    case Transizion.create_contract_purchase(contract_purchase_params) do
      {:ok, contract_purchase} ->
        conn
        |> redirect(to: Routes.admin_pod_path(conn, :show, contract_purchase.pod_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, pod: pod)
    end
  end

end
