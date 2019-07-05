defmodule TestAssoc do
  use Ecto.Schema
  import Ecto.Changeset

  schema "test_users" do
    field(:field, :string)
    belongs_to(:test_user, TestUser)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end
end
