defmodule TestUser do
  use Ecto.Schema

  schema "test_users" do
    field(:name, :string)
    field(:email, :string)
  end
end
