defmodule Reph.Single do
  @moduledoc false
  use Reph.Generator
  alias Reph.{Project}

  template :new, [
    {:text, "phx_single/gitignore",                     :project, ".gitignore"},
    {:eex,  "phx_single/config/config.exs",             :project, "config/config.exs"},
    {:eex,  "phx_single/config/dev.exs",                :project, "config/dev.exs"},
    {:eex,  "phx_single/config/prod.exs",               :project, "config/prod.exs"},
    {:eex,  "phx_single/config/prod.secret.exs",        :project, "config/prod.secret.exs"},
    {:eex,  "phx_single/config/test.exs",               :project, "config/test.exs"},
    {:eex,  "phx_single/lib/app_name/application.ex",   :project, "lib/:app/application.ex"},
    {:eex,  "phx_web/channels/user_socket.ex",          :project, "lib/:app/web/channels/user_socket.ex"},
    {:keep, "phx_web/controllers",                      :project, "lib/:app/web/controllers"},
    {:eex,  "phx_web/views/error_helpers.ex",           :project, "lib/:app/web/views/error_helpers.ex"},
    {:eex,  "phx_web/views/error_view.ex",              :project, "lib/:app/web/views/error_view.ex"},
    {:eex,  "phx_web/endpoint.ex",                      :project, "lib/:app/web/endpoint.ex"},
    {:eex,  "phx_web/router.ex",                        :project, "lib/:app/web/router.ex"},
    {:eex,  "phx_single/lib/app_name/web/web.ex",       :project, "lib/:app/web/web.ex"},
    {:eex,  "phx_single/mix.exs",                       :project, "mix.exs"},
    {:eex,  "phx_single/README.md",                     :project, "README.md"},
    {:eex,  "phx_test/support/channel_case.ex",         :project, "test/support/channel_case.ex"},
    {:eex,  "phx_test/support/conn_case.ex",            :project, "test/support/conn_case.ex"},
    {:eex,  "phx_single/test/test_helper.exs",          :project, "test/test_helper.exs"},
    {:keep, "phx_test/channels",                        :project, "test/:app/web/channels"},
    {:keep, "phx_test/controllers",                     :project, "test/:app/web/controllers"},
    {:eex,  "phx_test/views/error_view_test.exs",       :project, "test/:app/web/views/error_view_test.exs"},
  ]

  template :gettext, [
    {:eex,  "phx_gettext/gettext.ex",               :project, "lib/:app/web/gettext.ex"},
    {:eex,  "phx_gettext/en/LC_MESSAGES/errors.po", :project, "priv/gettext/en/LC_MESSAGES/errors.po"},
    {:eex,  "phx_gettext/errors.pot",               :project, "priv/gettext/errors.pot"}
  ]

  template :ecto, [
    {:eex,  "phx_ecto/repo.ex",              :project, "lib/:app/repo.ex"},
    {:keep, "phx_ecto/priv/repo/migrations", :project, "priv/repo/migrations"},
    {:eex,  "phx_ecto/seeds.exs",            :project, "priv/repo/seeds.exs"},
    {:eex,  "phx_ecto/data_case.ex",         :project, "test/support/data_case.ex"},
  ]

  template :react, [
    {:eex,  "phx_assets/babelrc",                       :project, "assets/.babelrc"},
    {:eex,  "phx_assets/webpack.config.js",             :project, "assets/webpack.config.js"},
    {:text, "phx_assets/styles/index.less",             :project, "assets/styles/index.less"},
    {:text, "phx_assets/styles/app.less",               :project, "assets/styles/app.less"},
    {:text, "phx_assets/styles/phoenix.css",            :project, "assets/styles/phoenix.css"},
    {:eex,  "phx_assets/js/index.js",                   :project, "assets/js/index.js"},
    {:eex,  "phx_assets/js/actions/ws.js",               :project, "assets/js/actions/ws.js"},
    {:eex,  "phx_assets/js/components/Header/index.js", :project, "assets/js/components/Header/index.js"},
    {:eex,  "phx_assets/js/components/Main/index.js",   :project, "assets/js/components/Main/index.js"},
    {:eex,  "phx_assets/js/containers/App/index.js",    :project, "assets/js/containers/App/index.js"},
    {:eex,  "phx_assets/js/containers/index.js",        :project, "assets/js/containers/index.js"},
    {:eex,  "phx_assets/js/reducers/index.js",          :project, "assets/js/reducers/index.js"},
    {:eex,  "phx_assets/js/reducers/ws.js",             :project, "assets/js/reducers/ws.js"},
    {:eex,  "phx_assets/js/routes/index.js",            :project, "assets/js/routes/index.js"},
    {:eex,  "phx_assets/js/store/index.js",             :project, "assets/js/store/index.js"},
    {:eex,  "phx_assets/package.json",                  :project, "assets/package.json"},
    {:text, "phx_assets/static/robots.txt",             :project, "assets/static/robots.txt"},
    {:keep, "phx_assets/vendor",                        :project, "assets/vendor"},
  ]

  template :html, [
    {:eex, "phx_web/controllers/react_controller.ex",        :project, "lib/:app/web/controllers/react_controller.ex"},
    {:eex, "phx_web/templates/layout/app.html.eex",          :project, "lib/:app/web/templates/layout/app.html.eex"},
    {:eex, "phx_web/templates/react/index.html.eex",         :project, "lib/:app/web/templates/react/index.html.eex"},
    {:eex, "phx_web/views/layout_view.ex",                   :project, "lib/:app/web/views/layout_view.ex"},
    {:eex, "phx_web/views/react_view.ex",                    :project, "lib/:app/web/views/react_view.ex"},
    {:eex, "phx_test/controllers/react_controller_test.exs", :project, "test/:app/web/controllers/react_controller_test.exs"},
    {:eex, "phx_test/views/layout_view_test.exs",            :project, "test/:app/web/views/layout_view_test.exs"},
    {:eex, "phx_test/views/react_view_test.exs",             :project, "test/:app/web/views/react_view_test.exs"},
  ]

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    %Project{project | project_path: project.base_path}
    |> put_app()
    |> put_root_app()
    |> put_web_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %Project{project |
             in_umbrella?: in_umbrella?(base_path),
             app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %Project{project |
             root_app: app,
             root_mod: Module.concat([opts[:module] || Macro.camelize(app)])}
  end

  defp put_web_app(%Project{app: app} = project) do
    %Project{project |
             web_app: app,
             web_namespace: Module.concat(project.root_mod, Web),
             web_path: project.project_path}
  end

  def generate(%Project{} = project) do
    copy_from project, __MODULE__, :new
    copy_from project, __MODULE__, :gettext

    if Project.ecto?(project), do: gen_ecto(project)
    gen_html(project)
    gen_react(project)
    project
  end

  defp gen_html(project) do
    copy_from project, __MODULE__, :html
  end

  defp gen_ecto(project) do
    copy_from project, __MODULE__, :ecto
    gen_ecto_config(project)
  end

  defp gen_react(%Project{web_path: web_path} = project) do
    copy_from project, __MODULE__, :react
    create_file Path.join(web_path, "assets/static/images/phoenix.png"), phoenix_png_text()
    create_file Path.join(web_path, "assets/static/favicon.ico"), phoenix_favicon_text()
  end
end
