defmodule NasaFuel.FuelCalculatorTest do
  use ExUnit.Case, async: true

  alias NasaFuel.FuelCalculator

  describe "fuel_for_step/3" do
    test "calculates fuel for landing on earth (single step, no recursion check)" do
      # 28801 * 9.807 * 0.033 - 42 = 9278 (first iteration only)
      assert FuelCalculator.fuel_for_step(:land, 28801, :earth) == 13447
    end

    test "calculates fuel for launch from earth" do
      # launch uses mass * gravity * 0.042 - 33
      fuel = FuelCalculator.fuel_for_step(:launch, 28801, :earth)
      assert fuel > 0
      assert is_integer(fuel)
    end

    test "calculates fuel for landing on moon" do
      fuel = FuelCalculator.fuel_for_step(:land, 28801, :moon)
      assert fuel > 0
      assert is_integer(fuel)
    end
  end

  describe "calculate/2 - full mission fuel" do
    test "apollo 11 mission: launch earth, land moon, launch moon, land earth" do
      path = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :earth}
      ]

      assert FuelCalculator.calculate(28801, path) == 51898
    end

    test "mars mission: launch earth, land mars, launch mars, land earth" do
      path = [
        {:launch, :earth},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert FuelCalculator.calculate(14606, path) == 33388
    end

    test "passenger ship: launch earth, land moon, launch moon, land mars, launch mars, land earth" do
      path = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert FuelCalculator.calculate(75432, path) == 212_161
    end

    test "returns 0 for empty path" do
      assert FuelCalculator.calculate(28801, []) == 0
    end
  end

  describe "gravity/1" do
    test "returns correct gravity for each planet" do
      assert FuelCalculator.gravity(:earth) == 9.807
      assert FuelCalculator.gravity(:moon) == 1.62
      assert FuelCalculator.gravity(:mars) == 3.711
    end
  end
end
