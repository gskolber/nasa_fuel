defmodule NasaFuelWeb.MissionLiveTest do
  use NasaFuelWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders the page with form and empty flight path", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "h1", "NASA Fuel Calculator")
      assert has_element?(view, "#mission-form")
      assert has_element?(view, "#empty-path")
    end
  end

  describe "adding steps" do
    test "adds a flight step to the path", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{action: "launch", planet: "earth", mass: "28801"})
      |> render_submit()

      assert has_element?(view, "#step-0")
      assert has_element?(view, "#flight-steps")
      refute has_element?(view, "#empty-path")
    end

    test "adds multiple steps", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{action: "launch", planet: "earth", mass: "28801"})
      |> render_submit()

      view
      |> form("#mission-form", mission: %{action: "land", planet: "moon", mass: "28801"})
      |> render_submit()

      assert has_element?(view, "#step-0")
      assert has_element?(view, "#step-1")
    end
  end

  describe "removing steps" do
    test "removes a step from the flight path", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{action: "launch", planet: "earth", mass: "28801"})
      |> render_submit()

      assert has_element?(view, "#step-0")

      view
      |> element("#step-0 button", "")
      |> render_click()

      refute has_element?(view, "#step-0")
      assert has_element?(view, "#empty-path")
    end
  end

  describe "fuel calculation" do
    test "apollo 11 mission shows correct total fuel", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      apollo_steps = [
        %{action: "launch", planet: "earth"},
        %{action: "land", planet: "moon"},
        %{action: "launch", planet: "moon"},
        %{action: "land", planet: "earth"}
      ]

      for step <- apollo_steps do
        view
        |> form("#mission-form", mission: Map.put(step, :mass, "28801"))
        |> render_submit()
      end

      assert has_element?(view, "#results")
      assert has_element?(view, "#total-fuel", "51,898")
    end

    test "does not show results without mass", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{action: "launch", planet: "earth", mass: ""})
      |> render_submit()

      refute has_element?(view, "#results")
    end

    test "recalculates when mass changes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{action: "launch", planet: "earth", mass: "28801"})
      |> render_submit()

      assert has_element?(view, "#results")

      view
      |> form("#mission-form", mission: %{mass: "14606"})
      |> render_change()

      assert has_element?(view, "#results")
    end
  end

  describe "validation" do
    test "shows error for negative mass", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{mass: "-5"})
      |> render_change()

      assert render(view) =~ "mass must be positive"
    end

    test "shows error for non-numeric mass", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#mission-form", mission: %{mass: "abc"})
      |> render_change()

      assert render(view) =~ "must be a valid number"
    end
  end
end
