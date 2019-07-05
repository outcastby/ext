defmodule TestUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "test_users" do
    field(:name, :string)
    field(:email, :string)
    has_many(:test_assoc, TestAssoc)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end
end