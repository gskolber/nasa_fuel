defmodule NasaFuel.FuelCalculator do
  @gravities %{
    earth: 9.807,
    moon: 1.62,
    mars: 3.711
  }

  def gravity(planet), do: Map.fetch!(@gravities, planet)

  def fuel_for_step(action, mass, planet) do
    g = gravity(planet)
    initial_fuel = base_fuel(action, mass, g)
    total_with_extra(action, initial_fuel, g)
  end

  def calculate(_mass, []), do: 0

  def calculate(mass, path) do
    path
    |> Enum.reverse()
    |> Enum.reduce(0, fn {action, planet}, acc_fuel ->
      step_fuel = fuel_for_step(action, mass + acc_fuel, planet)
      acc_fuel + step_fuel
    end)
  end

  defp base_fuel(:launch, mass, gravity), do: floor(mass * gravity * 0.042 - 33)
  defp base_fuel(:land, mass, gravity), do: floor(mass * gravity * 0.033 - 42)

  defp total_with_extra(_action, fuel, _gravity) when fuel <= 0, do: 0

  defp total_with_extra(action, fuel, gravity) do
    extra = base_fuel(action, fuel, gravity)

    if extra <= 0 do
      fuel
    else
      fuel + total_with_extra(action, extra, gravity)
    end
  end
end
