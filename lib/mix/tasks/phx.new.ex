defmodule Mix.Tasks.Phx.New do
  @moduledoc """
  Creates a new Phoenix project.

  It expects the path of the project as an argument.

      mix phx.new PATH [--module MODULE] [--app APP]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options

    * `--umbrella` - generate an umbrella application,
      with one application for your domain, and
      a second application for the web interface.

    * `--app` - the name of the OTP application

    * `--module` - the name of the base module in
      the generated skeleton

    * `--database` - specify the database adapter for ecto.
      Values can be `postgres` or `mysql`. Defaults to `postgres`

    * `--no-ecto` - do not generate Ecto files.

    * `--binary-id` - use `binary_id` as primary key type
      in Ecto schemas

  When passing the `--no-ecto` flag, Phoenix generators such as
  `phx.gen.html`, `phx.gen.json` and `phx.gen.context` may no
  longer work as expected as they generate context files that rely
  on Ecto for the database access. In those cases, you can pass the
  `--no-context` flag to generate most of the HTML and JSON files
  but skip the context, allowing you to fill in the blanks as desired.

  ## Examples

      mix phx.new hello_world

  Is equivalent to:

      mix phx.new hello_world --module HelloWorld

  As an umbrella:

      mix phx.new hello --umbrella

  Would generate the following directory structure and modules:

      hello_umbrella/   Hello.Umbrella
        apps/
          hello/        Hello
          hello_web/    Hello.Web

  You can read more about umbrella projects using the
  official [Elixir guide](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html#umbrella-projects)
  """
  use Mix.Task
  alias Phx.New.{Generator, Project, Single, Umbrella, Web, Ecto}

  @version Mix.Project.config[:version]
  @shortdoc "Creates a new Phoenix v#{@version} application"

  @switches [ecto: :boolean,
             app: :string, module: :string, web_module: :string,
             database: :string, binary_id: :boolean,
             umbrella: :boolean]

  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info "Phoenix v#{@version}"
  end
  def run(argv) do
    elixir_version_check!()
    case parse_opts(argv) do
      {_opts, []}             -> Mix.Tasks.Help.run(["phx.new"])
      {opts, [base_path | _]} ->
        generator = if opts[:umbrella], do: Umbrella, else: Single
        generate(base_path, generator, opts)
    end
  end
  def run(argv, generator) do
    elixir_version_check!()
    case parse_opts(argv) do
      {_opts, []}             -> Mix.Tasks.Help.run(["phx.new"])
      {opts, [base_path | _]} -> generate(base_path, generator, opts)
    end
  end

  def generate(base_path, generator, opts) do
    base_path
    |> Project.new(opts)
    |> generator.prepare_project()
    |> Generator.put_binding()
    |> validate_project()
    |> generator.generate()
    |> prompt_to_install_deps(generator)
  end

  defp validate_project(%Project{opts: opts} = project) do
    check_app_name!(project.app, !!opts[:app])
    check_directory_existence!(project.project_path)
    check_module_name_validity!(project.root_mod)
    check_module_name_availability!(project.root_mod)

    project
  end

  defp prompt_to_install_deps(%Project{} = project, generator) do
    install? = Mix.shell.yes?("\nFetch and install dependencies?")

    maybe_cd(project.project_path, fn ->
      mix_pending =
        install_mix(install?)

      brunch_pending =
        maybe_cd(project.web_path, fn ->
          compile =
            case mix_pending do
              [] -> Task.async(fn -> cmd("mix deps.compile") end)
              _  -> Task.async(fn -> :ok end)
            end

          brunch_pending = install_brunch(install?)
          Task.await(compile, :infinity)

          if !System.find_executable("npm") do
            print_brunch_info(project, generator)
          end

          brunch_pending
        end)

      pending = mix_pending ++ (brunch_pending || [])
      print_missing_commands(pending, project.project_path)

      if Project.ecto?(project) do
        print_ecto_info(project, generator)
      end

      print_mix_info(generator)
    end)
  end
  defp maybe_cd(path, func), do: path && File.cd!(path, func)

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: @switches) do
      {opts, argv, []} ->
        {opts, argv}
      {_opts, _argv, [switch | _]} ->
        Mix.raise "Invalid option: " <> switch_to_string(switch)
    end
  end
  defp switch_to_string({name, nil}), do: name
  defp switch_to_string({name, val}), do: name <> "=" <> val

  defp install_brunch(install?) do
    maybe_cmd "cd assets && npm install && node node_modules/brunch/bin/brunch build",
              File.exists?("assets/brunch-config.js"), install? && System.find_executable("npm")
  end

  defp install_mix(install?) do
    maybe_cmd "mix deps.get", true, install? && Code.ensure_loaded?(Hex)
  end

  defp print_brunch_info(_project, _gen) do
    Mix.shell.info """
    Phoenix uses an optional assets build tool called brunch.io
    that requires node.js and npm. Installation instructions for
    node.js, which includes npm, can be found at http://nodejs.org.

    The command listed next expect that you have npm available.
    """
  end

  defp print_missing_commands([], path) do
    Mix.shell.info """

    We are all set! Go into your application by running:

        $ cd #{relative_app_path(path)}
    """
  end
  defp print_missing_commands(commands, path) do
    steps = ["$ cd #{relative_app_path(path)}" | commands]
    Mix.shell.info """

    We are almost there! The following steps are missing:

        #{Enum.join(steps, "\n    ")}
    """
  end

  defp print_ecto_info(%Project{}, Web), do: :ok
  defp print_ecto_info(%Project{app_path: nil}, _gen), do: :ok
  defp print_ecto_info(%Project{app_path: app_path} = project, _gen) do
    config_path =
      app_path
      |> Path.join("config/dev.exs")
      |> Path.relative_to(project.project_path)

    Mix.shell.info """
    Then configure your database in #{config_path} and run:

        $ mix ecto.create
    """
  end

  defp print_mix_info(gen) when gen in [Ecto] do
    Mix.shell.info """
    You can run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix
    """
  end
  defp print_mix_info(_gen) do
    Mix.shell.info """
    Start your Phoenix app with:

        $ mix phx.server

    You can also run your app inside IEx (Interactive Elixir) as:

        $ iex -S mix phx.server
    """
  end
  defp relative_app_path(path) do
    case Path.relative_to_cwd(path) do
      ^path -> Path.basename(path)
      rel   -> rel
    end
  end

  ## Helpers

  @doc false
  def recompile(regex) do
    if Code.ensure_loaded?(Regex) and function_exported?(Regex, :recompile!, 1) do
      apply(Regex, :recompile!, [regex])
    else
      regex
    end
  end

  defp maybe_cmd(cmd, should_run?, can_run?) do
    cond do
      should_run? && can_run? ->
        cmd(cmd)
      should_run? ->
        ["$ #{cmd}"]
      true ->
        []
    end
  end

  defp cmd(cmd) do
    Mix.shell.info [:green, "* running ", :reset, cmd]
    case Mix.shell.cmd(cmd, quiet: true) do
      0 ->
        []
      _ ->
        ["$ #{cmd}"]
    end
  end

  defp check_app_name!(name, from_app_flag) do
    unless name =~ recompile(~r/^[a-z][\w_]*$/) do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
          "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise "Application name must start with a letter and have only lowercase " <>
                "letters, numbers and underscore, got: #{inspect name}" <> extra
    end
  end

  defp check_module_name_validity!(name) do
    unless inspect(name) =~ recompile(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect name}"
    end
  end

  defp check_module_name_availability!(name) do
    [name]
    |> Module.concat()
    |> Module.split()
    |> Enum.reduce([], fn name, acc ->
        mod = Module.concat([Elixir, name | acc])
        if Code.ensure_loaded?(mod) do
          Mix.raise "Module name #{inspect mod} is already taken, please choose another name"
        else
          [name | acc]
        end
    end)
  end

  defp check_directory_existence!(path) do
    if File.dir?(path) and not Mix.shell.yes?("The directory #{path} already exists. Are you sure you want to continue?") do
      Mix.raise "Please select another directory for installation."
    end
  end

  defp elixir_version_check! do
    unless Version.match?(System.version, "~> 1.4") do
      Mix.raise "Phoenix v#{@version} requires at least Elixir v1.4.\n " <>
                "You have #{System.version()}. Please update accordingly"
    end
  end
end
