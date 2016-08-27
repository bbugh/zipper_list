use ExGuard.Config

guard("unit-test", run_on_start: true)
|> command("mix test --color || tput bel")
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> notification(:auto)

guard("analysis")
|> command("mix dialyzer || tput bel")
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> notification(:auto)

guard("documentation", run_on_start: true)
|> command("mix docs")
|> watch(~r{\.(ex|exs|md)\z}i)
|> notification(:auto)
