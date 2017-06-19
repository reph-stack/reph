Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Reph.NewTest do
  use ExUnit.Case
  import MixHelper
  import ExUnit.CaptureIO

  @app_name "phx_blog"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  test "returns the version" do
    Mix.Tasks.Reph.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Reph v" <> _]}
  end

  test "new with defaults" do
    in_tmp "new with defaults", fn ->
      Mix.Tasks.Reph.New.run([@app_name])

      assert_file "phx_blog/README.md"
      assert_file "phx_blog/mix.exs", fn file ->
        assert file =~ "app: :phx_blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end

      assert_file "phx_blog/config/config.exs", fn file ->
        assert file =~ "ecto_repos: [PhxBlog.Repo]"
        refute file =~ "namespace: PhxBlog"
        refute file =~ "config :phx_blog, :generators"
      end

      assert_file "phx_blog/config/prod.exs", fn file ->
        assert file =~ "port: 80"
        assert file =~ ":inet6"
      end

      assert_file "phx_blog/lib/phx_blog/application.ex", ~r/defmodule PhxBlog.Application do/
      assert_file "phx_blog/mix.exs", ~r/mod: {PhxBlog.Application, \[\]}/
      assert_file "phx_blog/lib/phx_blog/web/web.ex", fn file ->
        assert file =~ "defmodule PhxBlog.Web do"
        assert file =~ "use Phoenix.View, root: \"lib/phx_blog/web/templates\""
      end
      assert_file "phx_blog/lib/phx_blog/web/endpoint.ex", ~r/defmodule PhxBlog.Web.Endpoint do/

      assert_file "phx_blog/test/phx_blog/web/controllers/react_controller_test.exs"
      assert_file "phx_blog/test/phx_blog/web/views/react_view_test.exs"
      assert_file "phx_blog/test/phx_blog/web/views/error_view_test.exs"
      assert_file "phx_blog/test/phx_blog/web/views/layout_view_test.exs"
      assert_file "phx_blog/test/support/conn_case.ex"
      assert_file "phx_blog/test/test_helper.exs"

      assert_file "phx_blog/lib/phx_blog/web/controllers/react_controller.ex",
                  ~r/defmodule PhxBlog.Web.ReactController/

      assert_file "phx_blog/lib/phx_blog/web/views/React_view.ex",
                  ~r/defmodule PhxBlog.Web.ReactView/

      assert_file "phx_blog/lib/phx_blog/web/router.ex", "defmodule PhxBlog.Web.Router"
      assert_file "phx_blog/lib/phx_blog/web/web.ex", "defmodule PhxBlog.Web"
      assert_file "phx_blog/lib/phx_blog/web/templates/layout/app.html.eex",
                  "<title>Hello PhxBlog!</title>"

      # React
      assert_file "phx_blog/.gitignore", "/node_modules"
      assert_file "phx_blog/assets/webpack.config.js", ~s("js/app.js": ["js/app"])
      assert_file "phx_blog/config/dev.exs", fn file ->
        assert file =~ "watchers: [node:"
        assert file =~ "lib/phx_blog/web/views/.*(ex)"
        assert file =~ "lib/phx_blog/web/templates/.*(eex)"
      end
      assert_file "phx_blog/assets/static/favicon.ico"
      assert_file "phx_blog/assets/static/images/phoenix.png"
      assert_file "phx_blog/assets/css/app.css"
      assert_file "phx_blog/assets/js/app.js",
                  ~s[import socket from "./socket"]
      assert_file "phx_blog/assets/js/socket.js",
                  ~s[import {Socket} from "phoenix"]

      assert_file "phx_blog/assets/package.json", fn file ->
        assert file =~ ~s["file:../deps/phoenix"]
        assert file =~ ~s["file:../deps/phoenix_html"]
      end

      refute File.exists? "phx_blog/priv/static/css/app.css"
      refute File.exists? "phx_blog/priv/static/js/phoenix.js"
      refute File.exists? "phx_blog/priv/static/js/app.js"

      assert File.exists?("phx_blog/assets/vendor")

      # Ecto
      config = ~r/config :phx_blog, PhxBlog.Repo,/
      assert_file "phx_blog/mix.exs", fn file ->
        assert file =~ "{:phoenix_ecto,"
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end
      assert_file "phx_blog/config/dev.exs", config
      assert_file "phx_blog/config/test.exs", config
      assert_file "phx_blog/config/prod.secret.exs", config
      assert_file "phx_blog/lib/phx_blog/repo.ex", ~r"defmodule PhxBlog.Repo"
      assert_file "phx_blog/priv/repo/seeds.exs", ~r"PhxBlog.Repo.insert!"
      assert_file "phx_blog/test/support/data_case.ex", ~r"defmodule PhxBlog.DataCase"
      assert_file "phx_blog/lib/phx_blog/web/web.ex", ~r"defmodule PhxBlog.Web"

      # Install dependencies?
      assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd phx_blog"
      assert msg =~ "$ mix deps.get"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}

      # Channels
      assert File.exists?("phx_blog/lib/phx_blog/web/channels")
      assert_file "phx_blog/lib/phx_blog/web/channels/user_socket.ex", ~r"defmodule PhxBlog.Web.UserSocket"
      assert_file "phx_blog/lib/phx_blog/web/endpoint.ex", ~r"socket \"/socket\", PhxBlog.Web.UserSocket"
      assert File.exists?("phx_blog/test/phx_blog/web/channels")

      # Gettext
      assert_file "phx_blog/lib/phx_blog/web/gettext.ex", ~r"defmodule PhxBlog.Web.Gettext"
      assert File.exists?("phx_blog/priv/gettext/errors.pot")
      assert File.exists?("phx_blog/priv/gettext/en/LC_MESSAGES/errors.po")
    end
  end

  test "new without defaults" do
    in_tmp "new without defaults", fn ->
      Mix.Tasks.Reph.New.run([@app_name, "--no-ecto"])

      # No Ecto
      config = ~r/config :phx_blog, PhxBlog.Repo,/
      refute File.exists?("phx_blog/lib/phx_blog/repo.ex")

      assert_file "phx_blog/mix.exs", &refute(&1 =~ ~r":phoenix_ecto")

      assert_file "phx_blog/config/config.exs", fn file ->
        refute file =~ "config :phx_blog, :generators"
        refute file =~ "ecto_repos:"
      end

      assert_file "phx_blog/config/dev.exs", &refute(&1 =~ config)
      assert_file "phx_blog/config/test.exs", &refute(&1 =~ config)
      assert_file "phx_blog/config/prod.secret.exs", &refute(&1 =~ config)
      assert_file "phx_blog/lib/phx_blog/web/web.ex", &refute(&1 =~ ~r"alias PhxBlog.Repo")
    end
  end

  test "new with binary_id" do
    in_tmp "new with binary_id", fn ->
      Mix.Tasks.Reph.New.run([@app_name, "--binary-id"])
      assert_file "phx_blog/config/config.exs", ~r/generators: \[binary_id: true\]/
    end
  end

  test "new with uppercase" do
    in_tmp "new with uppercase", fn ->
      Mix.Tasks.Reph.New.run(["phxBlog"])

      assert_file "phxBlog/README.md"

      assert_file "phxBlog/mix.exs", fn file ->
        assert file =~ "app: :phxBlog"
      end

      assert_file "phxBlog/config/dev.exs", fn file ->
        assert file =~ ~r/config :phxBlog, PhxBlog.Repo,/
        assert file =~ "database: \"phxblog_dev\""
      end
    end
  end

  test "new with path, app and module" do
    in_tmp "new with path, app and module", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Reph.New.run([project_path, "--app", @app_name, "--module", "PhoteuxBlog"])

      assert_file "custom_path/.gitignore"
      assert_file "custom_path/mix.exs", ~r/app: :phx_blog/
      assert_file "custom_path/lib/phx_blog/web/endpoint.ex", ~r/app: :phx_blog/
      assert_file "custom_path/config/config.exs", ~r/namespace: PhoteuxBlog/
      assert_file "custom_path/lib/phx_blog/web/web.ex", ~r/use Phoenix.Controller, namespace: PhoteuxBlog.Web/
    end
  end

  test "new inside umbrella" do
    in_tmp "new inside umbrella", fn ->
      File.write! "mix.exs", MixHelper.umbrella_mixfile_contents()
      File.mkdir! "apps"
      File.cd! "apps", fn ->
        Mix.Tasks.Reph.New.run([@app_name])

        assert_file "phx_blog/mix.exs", fn file ->
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end

        assert_file "phx_blog/assets/package.json", fn file ->
          assert file =~ ~s["file:../../../deps/phoenix"]
          assert file =~ ~s["file:../../../deps/phoenix_html"]
        end
      end
    end
  end

  test "new with mysql adapter" do
    in_tmp "new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Reph.New.run([project_path, "--database", "mysql"])

      assert_file "custom_path/mix.exs", ~r/:mariaex/
      assert_file "custom_path/config/dev.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/test.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/prod.secret.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/data_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
    end
  end

  test "new defaults to pg adapter" do
    in_tmp "new defaults to pg adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Reph.New.run([project_path])

      assert_file "custom_path/mix.exs", ~r/:postgrex/
      assert_file "custom_path/config/dev.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file "custom_path/config/test.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file "custom_path/config/prod.secret.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/]

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
      assert_file "custom_path/test/support/data_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
    end
  end

  test "new with invalid database adapter" do
    in_tmp "new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Reph.New.run([project_path, "--database", "invalid"])
      end
    end
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Reph.New.run ["007invalid"]
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Reph.New.run ["valid", "--app", "007invalid"]
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Reph.New.run ["valid", "--module", "not.valid"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["string"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["valid", "--app", "mix"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["valid", "--module", "String"]
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Reph.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp "new without args", fn ->
      assert capture_io(fn -> Mix.Tasks.Reph.New.run([]) end) =~
             "Creates a new Reph project."
    end
  end
end
