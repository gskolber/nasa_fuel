# NASA Fuel Calculator

A Phoenix LiveView application that calculates fuel requirements for interplanetary missions.

## How it works

Users build a flight path by adding launch/land steps for different planets, input the spacecraft mass, and the app calculates total fuel in real-time.

Fuel is computed recursively: the weight of fuel itself requires additional fuel, until the additional amount is zero or negative.

**Formulas:**
- Launch: `mass * gravity * 0.042 - 33` (rounded down)
- Landing: `mass * gravity * 0.033 - 42` (rounded down)

**Supported planets:** Earth (9.807), Moon (1.62), Mars (3.711)

## Example scenarios

| Mission | Mass (kg) | Path | Total Fuel (kg) |
|---|---|---|---|
| Apollo 11 | 28,801 | Launch Earth, Land Moon, Launch Moon, Land Earth | 51,898 |
| Mars | 14,606 | Launch Earth, Land Mars, Launch Mars, Land Earth | 33,388 |
| Passenger Ship | 75,432 | Launch Earth, Land Moon, Launch Moon, Land Mars, Launch Mars, Land Earth | 212,161 |

## Getting started

```bash
mix setup
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000).

## Running tests

```bash
mix test
```

## Code quality

```bash
mix credo --strict      # linting
mix dialyzer            # static analysis
MIX_ENV=test mix coveralls  # test coverage
mix precommit           # runs all checks
```

## Tech stack

- Elixir 1.18 / Erlang/OTP 27
- Phoenix 1.8 with LiveView
- Tailwind CSS with daisyUI
