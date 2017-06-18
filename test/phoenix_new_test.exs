Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Phoenix.NewTest do
  use ExUnit.Case
  import MixHelper

  import ExUnit.CaptureIO

  @app_name "photo_blog"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  test "returns the version" do
    Mix.Tasks.Phoenix.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Phoenix v" <> _]}
  end

  test "new with defaults" do
    in_tmp "new with defaults", fn ->
      Mix.Tasks.Phoenix.New.run([@app_name])

      assert_file "photo_blog/README.md"
      assert_file "photo_blog/mix.exs", fn file ->
        assert file =~ "app: :photo_blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end

      assert_file "photo_blog/config/config.exs", fn file ->
        assert file =~ "ecto_repos: [PhotoBlog.Repo]"
        refute file =~ "namespace"
        refute file =~ "config :phoenix, :generators"
      end

      assert_file "photo_blog/config/prod.exs", fn file ->
        assert file =~ "port: 80"
        assert file =~ ":inet6"
      end

      assert_file "photo_blog/lib/photo_blog.ex", ~r/defmodule PhotoBlog do/
      assert_file "photo_blog/lib/photo_blog/endpoint.ex", ~r/defmodule PhotoBlog.Endpoint do/

      assert_file "photo_blog/test/controllers/page_controller_test.exs"
      assert_file "photo_blog/test/views/page_view_test.exs"
      assert_file "photo_blog/test/views/error_view_test.exs"
      assert_file "photo_blog/test/views/layout_view_test.exs"
      assert_file "photo_blog/test/support/conn_case.ex"
      assert_file "photo_blog/test/test_helper.exs"

      assert_file "photo_blog/web/controllers/page_controller.ex",
                  ~r/defmodule PhotoBlog.PageController/

      assert File.exists?("photo_blog/web/models")

      assert_file "photo_blog/web/views/page_view.ex",
                  ~r/defmodule PhotoBlog.PageView/

      assert_file "photo_blog/web/router.ex", "defmodule PhotoBlog.Router"
      assert_file "photo_blog/web/web.ex", "defmodule PhotoBlog.Web"
      assert_file "photo_blog/web/templates/layout/app.html.eex",
                  "<title>Hello PhotoBlog!</title>"

      # Brunch
      assert_file "photo_blog/.gitignore", "/node_modules"
      assert_file "photo_blog/brunch-config.js", ~s("js/app.js": ["web/static/js/app"])
      assert_file "photo_blog/config/dev.exs", "watchers: [node:"
      assert_file "photo_blog/web/static/assets/favicon.ico"
      assert_file "photo_blog/web/static/assets/images/phoenix.png"
      assert_file "photo_blog/web/static/css/app.css"
      assert_file "photo_blog/web/static/js/app.js",
                  ~s[import socket from "./socket"]
      assert_file "photo_blog/web/static/js/socket.js",
                  ~s[import {Socket} from "phoenix"]

      assert_file "photo_blog/package.json", fn(file) ->
        assert file =~ ~s["file:deps/phoenix"]
        assert file =~ ~s["file:deps/phoenix_html"]
      end

      refute File.exists? "photo_blog/priv/static/css/app.css"
      refute File.exists? "photo_blog/priv/static/js/phoenix.js"
      refute File.exists? "photo_blog/priv/static/js/app.js"

      assert File.exists?("photo_blog/web/static/vendor")

      # Ecto
      config = ~r/config :photo_blog, PhotoBlog.Repo,/
      assert_file "photo_blog/mix.exs", fn file ->
        assert file =~ "{:phoenix_ecto,"
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end
      assert_file "photo_blog/config/dev.exs", config
      assert_file "photo_blog/config/test.exs", config
      assert_file "photo_blog/config/prod.secret.exs", config
      assert_file "photo_blog/lib/photo_blog/repo.ex", ~r"defmodule PhotoBlog.Repo"
      assert_file "photo_blog/priv/repo/seeds.exs", ~r"PhotoBlog.Repo.insert!"
      assert_file "photo_blog/test/support/model_case.ex", ~r"defmodule PhotoBlog.ModelCase"
      assert_file "photo_blog/web/web.ex", ~r"alias PhotoBlog.Repo"

      # Install dependencies?
      assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are all set!" <> _ = msg]}
      assert msg =~ "$ cd photo_blog"
      assert msg =~ "$ mix phoenix.server"

      assert_received {:mix_shell, :info, ["Before moving on, configure your database in config/dev.exs" <> _ = msg]}
      assert msg =~ "$ mix ecto.create"

      # Channels
      assert File.exists?("photo_blog/web/channels")
      assert_file "photo_blog/web/channels/user_socket.ex", ~r"defmodule PhotoBlog.UserSocket"
      assert_file "photo_blog/lib/photo_blog/endpoint.ex", ~r"socket \"/socket\", PhotoBlog.UserSocket"

      # Gettext
      assert_file "photo_blog/web/gettext.ex", ~r"defmodule PhotoBlog.Gettext"
      assert File.exists?("photo_blog/priv/gettext/errors.pot")
      assert File.exists?("photo_blog/priv/gettext/en/LC_MESSAGES/errors.po")
    end
  end

  test "new without defaults" do
    in_tmp "new without defaults", fn ->
      Mix.Tasks.Phoenix.New.run([@app_name, "--no-html", "--no-brunch", "--no-ecto"])

      # No Brunch
      refute File.read!("photo_blog/.gitignore") |> String.contains?("/node_modules")
      assert_file "photo_blog/config/dev.exs", ~r/watchers: \[\]/

      # No Brunch & No Html
      refute_file "photo_blog/priv/static/css/app.css"
      refute_file "photo_blog/priv/static/favicon.ico"
      refute_file "photo_blog/priv/static/images/phoenix.png"
      refute_file "photo_blog/priv/static/js/phoenix.js"
      refute_file "photo_blog/priv/static/js/app.js"

      # No Ecto
      config = ~r/config :photo_blog, PhotoBlog.Repo,/
      refute File.exists?("photo_blog/lib/photo_blog/repo.ex")

      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_ecto")

      assert_file "photo_blog/config/config.exs", fn file ->
        refute file =~ "config :phoenix, :generators"
        refute file =~ "ecto_repos:"
      end

      assert_file "photo_blog/config/dev.exs", &refute(&1 =~ config)
      assert_file "photo_blog/config/test.exs", &refute(&1 =~ config)
      assert_file "photo_blog/config/prod.secret.exs", &refute(&1 =~ config)
      assert_file "photo_blog/web/web.ex", &refute(&1 =~ ~r"alias PhotoBlog.Repo")

      # No HTML
      assert File.exists?("photo_blog/test/controllers")

      assert File.exists?("photo_blog/web/controllers")
      assert File.exists?("photo_blog/web/views")

      refute File.exists? "photo_blog/test/controllers/pager_controller_test.exs"
      refute File.exists? "photo_blog/test/views/layout_view_test.exs"
      refute File.exists? "photo_blog/test/views/page_view_test.exs"
      refute File.exists? "photo_blog/web/controllers/page_controller.ex"
      refute File.exists? "photo_blog/web/templates/layout/app.html.eex"
      refute File.exists? "photo_blog/web/templates/page/index.html.eex"
      refute File.exists? "photo_blog/web/views/layout_view.ex"
      refute File.exists? "photo_blog/web/views/page_view.ex"

      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_html")
      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_live_reload")
      assert_file "photo_blog/lib/photo_blog/endpoint.ex",
                  &refute(&1 =~ ~r"Phoenix.LiveReloader")
      assert_file "photo_blog/lib/photo_blog/endpoint.ex",
                  &refute(&1 =~ ~r"Phoenix.LiveReloader.Socket")
      assert_file "photo_blog/web/views/error_view.ex", ~r".json"
      assert_file "photo_blog/web/router.ex", &refute(&1 =~ ~r"pipeline :browser")
    end
  end

  test "new with no_brunch" do
    in_tmp "new with no_brunch", fn ->
      Mix.Tasks.Phoenix.New.run([@app_name, "--no-brunch"])

      assert_file "photo_blog/.gitignore"
      assert_file "photo_blog/priv/static/css/app.css"
      assert_file "photo_blog/priv/static/favicon.ico"
      assert_file "photo_blog/priv/static/images/phoenix.png"
      assert_file "photo_blog/priv/static/js/phoenix.js"
      assert_file "photo_blog/priv/static/js/app.js"
    end
  end

  test "new with binary_id" do
    in_tmp "new with binary_id", fn ->
      Mix.Tasks.Phoenix.New.run([@app_name, "--binary-id"])

      assert_file "photo_blog/web/web.ex", fn file ->
        assert file =~ ~r/@primary_key {:id, :binary_id, autogenerate: true}/
        assert file =~ ~r/@foreign_key_type :binary_id/
      end

      assert_file "photo_blog/config/config.exs", ~r/binary_id: true/
    end
  end

  test "new with uppercase" do
    in_tmp "new with uppercase", fn ->
      Mix.Tasks.Phoenix.New.run(["photoBlog"])

      assert_file "photoBlog/README.md"

      assert_file "photoBlog/mix.exs", fn file ->
        assert file =~ "app: :photoBlog"
      end

      assert_file "photoBlog/config/dev.exs", fn file ->
        assert file =~ ~r/config :photoBlog, PhotoBlog.Repo,/
        assert file =~ "database: \"photoblog_dev\""
      end
    end
  end

  test "new with path, app and module" do
    in_tmp "new with path, app and module", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.New.run([project_path, "--app", @app_name, "--module", "PhoteuxBlog"])

      assert_file "custom_path/.gitignore"
      assert_file "custom_path/mix.exs", ~r/app: :photo_blog/
      assert_file "custom_path/lib/photo_blog/endpoint.ex", ~r/app: :photo_blog/
      assert_file "custom_path/config/config.exs", ~r/namespace: PhoteuxBlog/
      assert_file "custom_path/web/web.ex", ~r/use Phoenix.Controller, namespace: PhoteuxBlog/
    end
  end

  test "new inside umbrella" do
    in_tmp "new inside umbrella", fn ->
      File.write! "mix.exs", umbrella_mixfile_contents()
      File.mkdir! "apps"
      File.cd! "apps", fn ->
        Mix.Tasks.Phoenix.New.run([@app_name])

        assert_file "photo_blog/mix.exs", fn(file) ->
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end

        assert_file "photo_blog/package.json", fn(file) ->
          assert file =~ ~s["file:../../deps/phoenix"]
          assert file =~ ~s["file:../../deps/phoenix_html"]
        end
      end
    end
  end

  test "new with mysql adapter" do
    in_tmp "new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.New.run([project_path, "--database", "mysql"])

      assert_file "custom_path/mix.exs", ~r/:mariaex/
      assert_file "custom_path/config/dev.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/test.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/prod.secret.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/model_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
    end
  end

  test "new defaults to pg adapter" do
    in_tmp "new defaults to pg adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.New.run([project_path])

      assert_file "custom_path/mix.exs", ~r/:postgrex/
      assert_file "custom_path/config/dev.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file "custom_path/config/test.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/, ~r/hostname: "localhost"/]
      assert_file "custom_path/config/prod.secret.exs", [~r/Ecto.Adapters.Postgres/, ~r/username: "postgres"/, ~r/password: "postgres"/]

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
      assert_file "custom_path/test/support/model_case.ex", "Ecto.Adapters.SQL.Sandbox.checkout"
    end
  end

  test "new with invalid database adapter" do
    in_tmp "new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Phoenix.New.run([project_path, "--database", "invalid"])
      end
    end
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phoenix.New.run ["007invalid"]
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phoenix.New.run ["valid", "--app", "007invalid"]
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Phoenix.New.run ["valid", "--module", "not.valid"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.New.run ["string"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.New.run ["valid", "--app", "mix"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.New.run ["valid", "--module", "String"]
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Phoenix.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp "new without args", fn ->

      output =
        capture_io fn ->
          Mix.Tasks.Phoenix.New.run []
        end

      assert output =~ "mix phoenix.new"
      assert output =~ "Creates a new Phoenix project."
    end
  end
end
