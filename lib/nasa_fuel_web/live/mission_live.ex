defmodule NasaFuelWeb.MissionLive do
  use NasaFuelWeb, :live_view

  alias NasaFuel.FuelCalculator

  @planets [
    {"Earth", "earth"},
    {"Moon", "moon"},
    {"Mars", "mars"}
  ]

  @actions [
    {"Launch", "launch"},
    {"Land", "land"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        planets: @planets,
        actions: @actions,
        steps: [],
        mass: nil,
        total_fuel: nil,
        errors: %{}
      )
      |> assign(form: to_form(%{"mass" => "", "action" => "launch", "planet" => "earth"}, as: :mission))

    {:ok, socket}
  end

  @impl true
  def handle_event("add_step", %{"mission" => params}, socket) do
    action = String.to_existing_atom(params["action"])
    planet = String.to_existing_atom(params["planet"])
    step = {action, planet}

    steps = socket.assigns.steps ++ [step]
    form = to_form(params, as: :mission)
    socket = assign(socket, steps: steps, form: form)
    socket = recalculate(socket)

    {:noreply, socket}
  end

  def handle_event("remove_step", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    steps = List.delete_at(socket.assigns.steps, index)
    socket = assign(socket, steps: steps)
    socket = recalculate(socket)

    {:noreply, socket}
  end

  def handle_event("validate", %{"mission" => params}, socket) do
    mass_str = params["mass"] || ""

    errors =
      case parse_mass(mass_str) do
        {:ok, _} -> Map.delete(socket.assigns.errors, :mass)
        {:error, msg} when mass_str != "" -> Map.put(socket.assigns.errors, :mass, msg)
        {:error, _} -> Map.delete(socket.assigns.errors, :mass)
      end

    form = to_form(params, as: :mission)
    socket = assign(socket, form: form, errors: errors)
    socket = recalculate_with_mass(socket, mass_str)

    {:noreply, socket}
  end

  defp parse_mass(""), do: {:error, "mass is required"}
  defp parse_mass(str) do
    case Integer.parse(str) do
      {n, ""} when n > 0 -> {:ok, n}
      {n, ""} when n <= 0 -> {:error, "mass must be positive"}
      _ ->
        case Float.parse(str) do
          {n, ""} when n > 0 -> {:ok, trunc(n)}
          {n, ""} when n <= 0 -> {:error, "mass must be positive"}
          _ -> {:error, "must be a valid number"}
        end
    end
  end

  defp recalculate(socket) do
    mass_str = socket.assigns.form.params["mass"] || ""
    recalculate_with_mass(socket, mass_str)
  end

  defp recalculate_with_mass(socket, mass_str) do
    case parse_mass(mass_str) do
      {:ok, mass} when socket.assigns.steps != [] ->
        total = FuelCalculator.calculate(mass, socket.assigns.steps)
        assign(socket, mass: mass, total_fuel: total)

      {:ok, mass} ->
        assign(socket, mass: mass, total_fuel: nil)

      {:error, _} ->
        assign(socket, mass: nil, total_fuel: nil)
    end
  end

  defp format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/.{3}/, "\\0,")
    |> String.reverse()
    |> String.trim_leading(",")
  end

  defp action_label(:launch), do: "Launch"
  defp action_label(:land), do: "Land"

  defp planet_label(:earth), do: "Earth"
  defp planet_label(:moon), do: "Moon"
  defp planet_label(:mars), do: "Mars"
end
