defmodule Ext.Utils.Date do
  def from(str) do
    {:ok, date, _} = DateTime.from_iso8601(str)
    date
  end

  @shift_types [:days, :hours, :minutes, :seconds]
  @doc ~S"""
  Convert to Timex.shift params.

  ## Examples

      iex> Ext.Utils.Date.shift_normalize(:minutes, 1.5)
      [seconds: 90]

      iex> Ext.Utils.Date.shift_normalize(:hours, 1.51)
      [seconds: 5436]

      iex> Ext.Utils.Date.shift_normalize(:seconds, 1.51)
      [seconds: 1]

      iex> Ext.Utils.Date.shift_normalize(:days, 1.5)
      [hours: 36]

      iex> Ext.Utils.Date.shift_normalize(:minutes, -1.5)
      [seconds: -90]

  """
  def shift_normalize(type, value) when is_float(value) do
    floor_value = value |> Float.floor()

    cond do
      floor_value != value ->
        next_type = Enum.at(@shift_types, Enum.find_index(@shift_types, &(&1 == type)) + 1)
        value = shift_value_for_next_type(value, next_type)
        shift_normalize(unless(next_type, do: type, else: next_type), value)

      true ->
        [{type, trunc(value)}]
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

  def beginning_of_day(date) do
    Timex.beginning_of_day(date) |> Timex.format!("%FT%H:%M:%S.%f%:z", :strftime) |> Timex.parse!("{ISO:Extended}")
  end

  # TODO (denis) Timex.beginning_of_week works incorrectly
  def beginning_of_week(date) do
    date = Timex.beginning_of_week(date)

    cond do
      date |> Timex.days_to_beginning_of_week() == 0 -> date
      true -> beginning_of_week(date)
    end
  end

  def date_time_by_time_string(time, date_time \\ DateTime.utc_now()) do
    beginning_of_day = beginning_of_day(date_time)

    case String.split(time, ":") |> Enum.map(&Ext.Utils.Base.to_int(&1)) do
      [hours, minutes, seconds] -> Timex.shift(beginning_of_day, hours: hours, minutes: minutes, seconds: seconds)
      [hours, minutes] -> Timex.shift(beginning_of_day, hours: hours, minutes: minutes)
    end
  end
end
