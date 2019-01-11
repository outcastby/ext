defmodule Ext.Utils.Date do
  def now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end

  @shift_types [:days, :hours, :minutes, :seconds]
  @doc ~S"""
  Convert to Timex.shift params.

  ## Examples

      iex> Ext.Date.shift_normalize(:minutes, 1.5)
      [seconds: 90]

      iex> Ext.Date.shift_normalize(:hours, 1.51)
      [seconds: 5436]

      iex> Ext.Date.shift_normalize(:seconds, 1.51)
      [seconds: 1]

      iex> Ext.Date.shift_normalize(:days, 1.5)
      [hours: 36]

      iex> Ext.Date.shift_normalize(:minutes, -1.5)
      [seconds: -90]

  """
  def shift_normalize(type, value) when is_float(value) do
    floor_value = value |> Float.floor()

    cond do
      floor_value != value ->
        next_type = Enum.at(@shift_types, Enum.find_index(@shift_types, &(&1 == type)) + 1)
        value = shift_value_for_next_type(value, next_type)
        shift_normalize((unless next_type, do: type, else: next_type), value)
      true -> [{type, trunc(value)}]
    end
  end

  def shift_normalize(type, value), do: [{type, trunc(value)}]

  def shift_value_for_next_type(shift, type) do
    cond do
      Enum.member?([:days], type) -> shift * 7
      Enum.member?([:hours], type) -> shift * 24
      Enum.member?([:minutes, :seconds], type) -> shift * 60
      true -> shift |> Float.floor()
    end
  end

  # TODO (denis) Timex.beginning_of_week works incorrectly
  def beginning_of_week(date) do
    date = Timex.beginning_of_week(date)

    cond do
      date |> Timex.days_to_beginning_of_week() == 0 -> date
      true -> beginning_of_week(date)
    end
  end
end
