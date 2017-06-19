Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Reph.New.UmbrellaTest do
  use ExUnit.Case, async: true
  import MixHelper

  @app "phx_umb"

  setup config do
    # The shell asks to install deps.
    # We will politely say not.
    decline_prompt()
    {:ok, tmp_dir: to_string(config.test)}
  end

  defp decline_prompt do
    send self(), {:mix_shell_input, :yes?, false}
  end

  defp root_path(app, path \\ "") do
    Path.join(["#{app}_umbrella", path])
  end

  defp app_path(app, path) do
    Path.join(["#{app}_umbrella/apps/#{app}", path])
  end

  defp web_path(app, path) do
    Path.join(["#{app}_umbrella/apps/#{app}_web", path])
  end

  test "new with umbrella and defaults" do
    in_tmp "new with umbrella and defaults", fn ->
      Mix.Tasks.Reph.New.run([@app, "--umbrella"])

      assert_file root_path(@app, "README.md")
      assert_file root_path(@app, ".gitignore")
      assert_file app_path(@app, "README.md")
      assert_file app_path(@app, ".gitignore")
      assert_file web_path(@app, "README.md")
      assert_file root_path(@app, "mix.exs"), fn file ->
        assert file =~ "apps_path: \"apps\""
      end
      assert_file app_path(@app, "mix.exs"), fn file ->
        assert file =~ "app: :phx_umb"
        assert file =~ ~S{build_path: "../../_build"}
        assert file =~ ~S{config_path: "../../config/config.exs"}
        assert file =~ ~S{deps_path: "../../deps"}
        assert file =~ ~S{lockfile: "../../mix.lock"}
      end

      assert_file root_path(@app, "config/config.exs"), fn file ->
        assert file =~ ~S[import_config "../apps/*/config/config.exs"]
        assert file =~ ~S[import_config "#{Mix.env}.exs"]
      end
      assert_file app_path(@app, "config/config.exs"), fn file ->
        assert file =~ "ecto_repos: [PhxUmb.Repo]"
        refute file =~ "namespace"
        refute file =~ "config :phx_blog_web, :generators"
      end
      assert_file web_path(@app, "config/config.exs"), fn file ->
        assert file =~ "ecto_repos: [PhxUmb.Repo]"
        assert file =~ ":phx_umb_web, PhxUmb.Web.Endpoint"
        assert file =~ "namespace"
        assert file =~ "config :phx_umb_web, :generators,"
        assert file =~ "context_app: :phx_umb\n"
      end

      assert_file web_path(@app, "config/prod.exs"), fn file ->
        assert file =~ "port: 80"
        assert file =~ ":inet6"
      end

      assert_file app_path(@app, "lib/#{@app}/application.ex"), ~r/defmodule PhxUmb.Application do/
      assert_file app_path(@app, "mix.exs"), ~r/mod: {PhxUmb.Application, \[\]}/
      assert_file app_path(@app, "test/test_helper.exs")

      assert_file web_path(@app, "lib/#{@app}_web/application.ex"), ~r/defmodule PhxUmb.Web.Application do/
      assert_file web_path(@app, "mix.exs"), ~r/mod: {PhxUmb.Web.Application, \[\]}/
      assert_file web_path(@app, "lib/#{@app}_web.ex"), fn file ->
        assert file =~ "defmodule PhxUmb.Web do"
        assert file =~ "use Phoenix.View, root: \"lib/phx_umb_web/templates\""
      end
      assert_file web_path(@app, "lib/#{@app}_web/endpoint.ex"), ~r/defmodule PhxUmb.Web.Endpoint do/
      assert_file web_path(@app, "test/#{@app}_web/controllers/react_controller_test.exs")
      assert_file web_path(@app, "test/#{@app}_web/views/react_view_test.exs")
      assert_file web_path(@app, "test/#{@app}_web/views/error_view_test.exs")
      assert_file web_path(@app, "test/#{@app}_web/views/layout_view_test.exs")
      assert_file web_path(@app, "test/support/conn_case.ex")
      assert_file web_path(@app, "test/test_helper.exs")

      assert_file web_path(@app, "lib/#{@app}_web/controllers/react_controller.ex"),
                  ~r/defmodule PhxUmb.Web.ReactController/

      assert_file web_path(@app, "lib/#{@app}_web/views/react_view.ex"),
                  ~r/defmodule PhxUmb.Web.ReactView/

      assert_file web_path(@app, "lib/#{@app}_web/router.ex"), "defmodule PhxUmb.Web.Router"
      assert_file web_path(@app, "lib/#{@app}_web/templates/layout/app.html.eex"),
                  "<title>Hello PhxUmb!</title>"

      assert_file web_path(@app, "test/#{@app}_web/views/react_view_test.exs"),
                  "defmodule PhxUmb.Web.ReactViewTest"

      # React
      assert_file web_path(@app, ".gitignore"), "/node_modules"
      assert_file web_path(@app, "assets/webpack.config.js"), ~s("js/app.js": ["js/app"])
      assert_file web_path(@app, "config/dev.exs"), fn file ->
        assert file =~ "watchers: [node:"
        assert file =~ "lib/#{@app}_web/views/.*(ex)"
        assert file =~ "lib/#{@app}_web/templates/.*(eex)"
      end
      assert_file web_path(@app, "assets/static/favicon.ico")
      assert_file web_path(@app, "assets/static/images/phoenix.png")
      assert_file web_path(@app, "assets/styles/app.less")
      assert_file web_path(@app, "assets/js/app.js"),
                  ~s[import socket from "./socket"]
      assert_file web_path(@app, "assets/js/socket.js"),
                  ~s[import {Socket} from "phoenix"]

      assert_file web_path(@app, "assets/package.json"), fn file ->
        assert file =~ ~s["file:../../../deps/phoenix"]
        assert file =~ ~s["file:../../../deps/phoenix_html"]
      end

      refute File.exists?(web_path(@app, "priv/static/styles/app.less"))
      refute File.exists?(web_path(@app, "priv/static/js/phoenix.js"))
      refute File.exists?(web_path(@app, "priv/static/js/app.js"))

      assert File.exists?(web_path(@app, "assets/vendor"))

      # web deps
      assert_file web_path(@app, "mix.exs"), fn file ->
        assert file =~ "{:phx_umb, in_umbrella: true}"
        assert file =~ "{:phoenix,"
        assert file =~ "{:phoenix_pubsub,"
        assert file =~ "{:gettext,"
        assert file =~ "{:cowboy,"
      end

      # app deps
      assert_file web_path(@app, "mix.exs"), fn file ->
        assert file =~ "{:phoenix_ecto,"
      end

      # Ecto
      config = ~r/config :phx_umb, PhxUmb.Repo,/
      assert_file app_path(@app, "mix.exs"), fn file ->
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end

      assert_file app_path(@app, "config/dev.exs"), config
      assert_file app_path(@app, "config/test.exs"), config
      assert_file app_path(@app, "config/prod.secret.exs"), config
      assert_file app_path(@app, "lib/#{@app}/repo.ex"), ~r"defmodule PhxUmb.Repo"
      assert_file app_path(@app, "priv/repo/seeds.exs"), ~r"PhxUmb.Repo.insert!"
      assert_file app_path(@app, "test/support/data_case.ex"), ~r"defmodule PhxUmb.DataCase"

      # Install dependencies?
      assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd phx_umb"
      assert msg =~ "$ mix deps.get"

      assert_received {:mix_shell, :info, ["Then configure your database in apps/phx_umb/config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}

      # Channels
      assert File.exists?(web_path(@app, "/lib/#{@app}_web/channels"))
      assert_file web_path(@app, "lib/#{@app}_web/channels/user_socket.ex"), ~r"defmodule PhxUmb.Web.UserSocket"
      assert_file web_path(@app, "lib/#{@app}_web/endpoint.ex"), ~r"socket \"/socket\", PhxUmb.Web.UserSocket"

      # Gettext
      assert_file web_path(@app, "lib/#{@app}_web/gettext.ex"), ~r"defmodule PhxUmb.Web.Gettext"
      assert File.exists?(web_path(@app, "priv/gettext/errors.pot"))
      assert File.exists?(web_path(@app, "priv/gettext/en/LC_MESSAGES/errors.po"))
    end
  end

  test "new without defaults" do
    in_tmp "new without defaults", fn ->
      Mix.Tasks.Reph.New.run([@app, "--umbrella", "--no-ecto"])

      # No Ecto
      config = ~r/config :phx_umb, PhxUmb.Repo,/
      refute File.exists?(app_path(@app, "lib/#{@app}_web/repo.ex"))

      assert_file app_path(@app, "mix.exs"), &refute(&1 =~ ~r":phoenix_ecto")

      assert_file app_path(@app, "config/config.exs"), fn file ->
        refute file =~ "config :phx_blog_web, :generators"
        refute file =~ "ecto_repos:"
      end
      assert_file web_path(@app, "config/config.exs"), fn file ->
        refute file =~ "config :phx_blog_web, :generators"
      end

      assert_file web_path(@app, "config/dev.exs"), &refute(&1 =~ config)
      assert_file web_path(@app, "config/test.exs"), &refute(&1 =~ config)
      assert_file web_path(@app, "config/prod.secret.exs"), &refute(&1 =~ config)
    end
  end

  test "new with binary_id" do
    in_tmp "new with binary_id", fn ->
      Mix.Tasks.Reph.New.run([@app, "--umbrella", "--binary-id"])
      assert_file web_path(@app, "config/config.exs"), ~r/generators: \[binary_id: true\]/
    end
  end

  test "new with uppercase" do
    in_tmp "new with uppercase", fn ->
      Mix.Tasks.Reph.New.run(["phxUmb", "--umbrella"])

      assert_file "phxUmb_umbrella/README.md"

      assert_file "phxUmb_umbrella/apps/phxUmb/mix.exs", fn file ->
        assert file =~ "app: :phxUmb"
      end
      assert_file "phxUmb_umbrella/apps/phxUmb_web/mix.exs", fn file ->
        assert file =~ "app: :phxUmb_web"
      end

      assert_file "phxUmb_umbrella/apps/phxUmb/config/dev.exs", fn file ->
        assert file =~ ~r/config :phxUmb, PhxUmb.Repo,/
        assert file =~ "database: \"phxumb_dev\""
      end
    end
  end

  test "new with path, app and module" do
    in_tmp "new with path, app and module", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Reph.New.run([project_path, "--umbrella", "--app", @app, "--module", "PhoteuxBlog"])

      assert_file "custom_path_umbrella/apps/phx_umb/mix.exs", ~r/app: :phx_umb/
      assert_file "custom_path_umbrella/apps/phx_umb_web/lib/phx_umb_web/endpoint.ex", ~r/app: :#{@app}_web/
      assert_file "custom_path_umbrella/apps/phx_umb_web/config/config.exs", ~r/namespace: PhoteuxBlog.Web/
      assert_file "custom_path_umbrella/apps/phx_umb_web/lib/#{@app}_web.ex", ~r/use Phoenix.Controller, namespace: PhoteuxBlog.Web/
      assert_file "custom_path_umbrella/apps/phx_umb/lib/phx_umb/application.ex", ~r/defmodule PhoteuxBlog.Application/
      assert_file "custom_path_umbrella/apps/phx_umb/mix.exs", ~r/mod: {PhoteuxBlog.Application, \[\]}/
      assert_file "custom_path_umbrella/apps/phx_umb_web/lib/phx_umb_web/application.ex", ~r/defmodule PhoteuxBlog.Web.Application/
      assert_file "custom_path_umbrella/apps/phx_umb_web/mix.exs", ~r/mod: {PhoteuxBlog.Web.Application, \[\]}/
    end
  end

  test "new inside umbrella" do
    in_tmp "new inside umbrella", fn ->
      File.write! "mix.exs", MixHelper.umbrella_mixfile_contents()
      File.mkdir! "apps"
      File.cd! "apps", fn ->
        assert_raise Mix.Error, "Unable to nest umbrella project within apps", fn ->
          Mix.Tasks.Reph.New.run([@app, "--umbrella"])
        end
      end
    end
  end

  test "new with mysql adapter" do
    in_tmp "new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Reph.New.run([project_path, "--umbrella", "--database", "mysql"])

      assert_file "custom_path_umbrella/apps/custom_path/mix.exs", ~r/:mariaex/
      assert_file "custom_path_umbrella/apps/custom_path/config/dev.exs",
        [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path_umbrella/apps/custom_path/config/test.exs",
        [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path_umbrella/apps/custom_path/config/prod.secret.exs",
        [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]

      assert_file "custom_path_umbrella/apps/custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path_umbrella/apps/custom_path_web/test/support/channel_case.ex",
        "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path_umbrella/apps/custom_path_web/test/support/conn_case.ex",
        "Ecto.Adapters.SQL.Sandbox.mode"
    end
  end

  test "new defaults to pg adapter" do
    in_tmp "new defaults to pg adapter", fn ->
      app = "custom_path"
      project_path = Path.join(File.cwd!, app)
      Mix.Tasks.Reph.New.run([project_path, "--umbrella"])

      assert_file app_path(app, "mix.exs"), ~r/:postgrex/
      assert_file app_path(app, "config/dev.exs"), [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file app_path(app, "config/test.exs"), [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file app_path(app, "config/prod.secret.exs"), [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/]

      assert_file web_path(app, "test/support/conn_case.ex"), "Ecto.Adapters.SQL.Sandbox.checkout"
      assert_file web_path(app, "test/support/channel_case.ex"), "Ecto.Adapters.SQL.Sandbox.checkout"
    end
  end

  test "new with invalid database adapter" do
    in_tmp "new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Reph.New.run([project_path, "--umbrella", "--database", "invalid"])
      end
    end
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Reph.New.run ["007invalid", "--umbrella"]
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Reph.New.run ["valid1", "--app", "007invalid", "--umbrella"]
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Reph.New.run ["valid2", "--module", "not.valid", "--umbrella"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["string", "--umbrella"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["valid3", "--app", "mix", "--umbrella"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Reph.New.run ["valid4", "--module", "String", "--umbrella"]
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Reph.New.run(["valid5", "-database", "mysql", "--umbrella"])
    end
  end

  describe "web task" do
    test "can only be run within an umbrella app dir", %{tmp_dir: tmp_dir} do
      in_tmp tmp_dir, fn ->
        cwd = File.cwd!()
        umbrella_path = root_path(@app)
        Mix.Tasks.Reph.New.run([@app, "--umbrella"])
        flush()

        for dir <- [cwd, umbrella_path] do
          File.cd!(dir, fn ->
            assert_raise Mix.Error, ~r"The web task can only be run within an umbrella's apps directory", fn ->
              Mix.Tasks.Reph.New.Web.run(["valid"])
            end
          end)
        end
      end
    end

    test "generates web-only files", %{tmp_dir: tmp_dir} do
      in_tmp tmp_dir, fn ->
        umbrella_path = root_path(@app)
        Mix.Tasks.Reph.New.run([@app, "--umbrella"])
        flush()

        File.cd!(Path.join(umbrella_path, "apps"))
        decline_prompt()
        Mix.Tasks.Reph.New.Web.run(["another"])

        assert_file "another/README.md"
        assert_file "another/mix.exs", fn file ->
          assert file =~ "app: :another"
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end

        assert_file "another/config/config.exs", fn file ->
          assert file =~ "ecto_repos: [Another.Repo]"
        end

        assert_file "another/config/prod.exs", fn file ->
          assert file =~ "port: 80"
          assert file =~ ":inet6"
        end

        assert_file "another/lib/another/application.ex", ~r/defmodule Another.Application do/
        assert_file "another/mix.exs", ~r/mod: {Another.Application, \[\]}/
        assert_file "another/lib/another.ex", ~r/defmodule Another do/
        assert_file "another/lib/another/endpoint.ex", ~r/defmodule Another.Endpoint do/

        assert_file "another/test/another/controllers/react_controller_test.exs"
        assert_file "another/test/another/views/react_view_test.exs"
        assert_file "another/test/another/views/error_view_test.exs"
        assert_file "another/test/another/views/layout_view_test.exs"
        assert_file "another/test/support/conn_case.ex"
        assert_file "another/test/test_helper.exs"

        assert_file "another/lib/another/controllers/react_controller.ex",
                    ~r/defmodule Another.ReactController/

        assert_file "another/lib/another/views/react_view.ex",
                    ~r/defmodule Another.ReactView/

        assert_file "another/lib/another/router.ex", "defmodule Another.Router"
        assert_file "another/lib/another.ex", "defmodule Another"
        assert_file "another/lib/another/templates/layout/app.html.eex",
                    "<title>Hello Another!</title>"

        # React
        assert_file "another/.gitignore", "/node_modules"
        assert_file "another/assets/webpack.config.js", ~s("js/app.js": ["js/app"])
        assert_file "another/config/dev.exs", "watchers: [node:"
        assert_file "another/assets/static/favicon.ico"
        assert_file "another/assets/static/images/phoenix.png"
        assert_file "another/assets/styles/app.less"
        assert_file "another/assets/js/app.js",
                    ~s[import socket from "./socket"]
        assert_file "another/assets/js/socket.js",
                    ~s[import {Socket} from "phoenix"]

        assert_file "another/assets/package.json", fn file ->
          assert file =~ ~s["file:../../../deps/phoenix"]
          assert file =~ ~s["file:../../../deps/phoenix_html"]
        end

        refute File.exists? "another/priv/static/less/app.less"
        refute File.exists? "another/priv/static/js/phoenix.js"
        refute File.exists? "another/priv/static/js/app.js"

        assert File.exists?("another/assets/vendor")

        # Ecto
        assert_file "another/mix.exs", fn file ->
          assert file =~ "{:phoenix_ecto,"
        end
        assert_file "another/lib/another.ex", ~r"defmodule Another"
        refute_file "another/lib/another/repo.ex"
        refute_file "another/priv/repo/seeds.exs"
        refute_file "another/test/support/data_case.ex"

        # Install dependencies?
        assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

        # Instructions
        assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
        assert msg =~ "$ cd another"
        assert msg =~ "$ mix deps.get"

        refute_received {:mix_shell, :info, ["Then configure your database" <> _]}
        assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}

        # Channels
        assert File.exists?("another/lib/another/channels")
        assert_file "another/lib/another/channels/user_socket.ex", ~r"defmodule Another.UserSocket"
        assert_file "another/lib/another/endpoint.ex", ~r"socket \"/socket\", Another.UserSocket"

        # Gettext
        assert_file "another/lib/another/gettext.ex", ~r"defmodule Another.Gettext"
        assert File.exists?("another/priv/gettext/errors.pot")
        assert File.exists?("another/priv/gettext/en/LC_MESSAGES/errors.po")
      end
    end
  end
end
