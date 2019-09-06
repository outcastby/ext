defmodule Ext.Ecto.RepoTest do
  use ExUnit.Case
  require IEx
  import Ecto.Query

  test "where with map" do
    query =
      TestUser
      |> TestRepo.where(%{count: %{sign: "<", value: 10}})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 WHERE (t0.\"count\" < $1)",
              [10]}
  end

  test "where with OR" do
    query =
      TestUser
      |> TestRepo.where(%{id: 1, locale: "de"})
      |> TestRepo.where({:or, [%{name: "test", locale: "en"}, %{count: [">", 10], locale: "ru"}]})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 WHERE ((t0.\"id\" = $1) AND (t0.\"locale\" = $2)) AND (((t0.\"count\" > $3) AND (t0.\"locale\" = $4)) OR ((t0.\"locale\" = $5) AND (t0.\"name\" = $6)))",
              [1, "de", 10, "ru", "en", "test"]}

    # Formatted WHERE conditions: ((id = 1) && (locale = 2)) && (((count > 3) && (locale = 4)) || ((locale = 5) && (name = 6)))
  end

  test "two conditions with same key" do
    query = TestUser |> TestRepo.where(id: [">", 1], id: ["<", 3])

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 WHERE ((t0.\"id\" > $1) AND (t0.\"id\" < $2))",
              [1, 3]}
  end

  test "where with one join" do
    query =
      TestUser
      |> join(:inner, [tu], tma in assoc(tu, :test_many_assocs))
      |> TestRepo.where(%{name: "Test Name", test_many_assocs: %{field: ["=", "test"]}})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 INNER JOIN \"test_many_assocs\" AS t1 ON t1.\"test_user_id\" = t0.\"id\" WHERE ((t0.\"name\" = $1) AND (t1.\"field\" = $2))",
               ["Test Name", "test"]}
  end

  test "where with two join" do
    query =
      TestUser
      |> join(:inner, [tu], tma in assoc(tu, :test_many_assocs))
      |> join(:inner, [tu], toa in assoc(tu, :test_one_assoc))
      |> TestRepo.where(%{name: "Test Name", test_one_assoc: %{field: %{sign: ">", value: "test"}}})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 INNER JOIN \"test_many_assocs\" AS t1 ON t1.\"test_user_id\" = t0.\"id\" INNER JOIN \"test_one_assoc\" AS t2 ON t2.\"test_user_id\" = t0.\"id\" WHERE ((t0.\"name\" = $1) AND (t2.\"field\" > $2))",
               ["Test Name", "test"]}
  end

  test "where with nested join" do
    query =
      TestUser
      |> join(:inner, [tu], tma in assoc(tu, :test_many_assocs))
      |> join(:inner, [tu, tma], na in assoc(tma, :nested_assocs))
      |> TestRepo.where(test_many_assocs: %{field: "test1", nested_assocs: %{field: "test2"}})

    assert TestRepo.to_sql(:all, query) ==
             {"SELECT t0.\"id\", t0.\"name\", t0.\"email\", t0.\"count\", t0.\"locale\" FROM \"test_users\" AS t0 INNER JOIN \"test_many_assocs\" AS t1 ON t1.\"test_user_id\" = t0.\"id\" INNER JOIN \"nested_assocs\" AS n2 ON n2.\"test_many_assoc_id\" = t1.\"id\" WHERE ((t1.\"field\" = $1) AND (n2.\"field\" = $2))",
               ["test1", "test2"]}
  end
end
