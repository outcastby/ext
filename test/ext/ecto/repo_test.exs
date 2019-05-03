defmodule Ext.Ecto.RepoTest do
  use ExUnit.Case
  require IEx

  defmodule User do
    use Ecto.Schema

    schema "user" do
      field(:name, :string)
      field(:count, :integer)
      field(:locale, :string)
    end
  end

  test "where with OR" do
    query =
      User
      |> TestRepo.where(%{id: 1, locale: "de"})
      |> TestRepo.where({:or, [%{name: "test", locale: "en"}, %{count: [">", 10], locale: "ru"}]})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT u0.\"id\", u0.\"name\", u0.\"count\", u0.\"locale\" FROM \"user\" AS u0 WHERE ((u0.\"id\" = $1) AND (u0.\"locale\" = $2)) AND (((u0.\"count\" > $3) AND (u0.\"locale\" = $4)) OR ((u0.\"locale\" = $5) AND (u0.\"name\" = $6)))",
              [1, "de", 10, "ru", "en", "test"]}

    # Formatted WHERE conditions: ((id = 1) && (locale = 2)) && (((count > 3) && (locale = 4)) || ((locale = 5) && (name = 6)))
  end

  test "two conditions with same key" do
    query = User |> TestRepo.where(id: [">", 1], id: ["<", 3])

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT u0.\"id\", u0.\"name\", u0.\"count\", u0.\"locale\" FROM \"user\" AS u0 WHERE ((u0.\"id\" > $1) AND (u0.\"id\" < $2))",
              [1, 3]}
  end
end
