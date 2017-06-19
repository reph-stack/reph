defmodule Reph.Web do
  @moduledoc false
  use Reph.Generator
  alias Reph.{Project}

  @pre "phx_umbrella/apps/app_name_web"

  template :new, [
    {:eex,  "#{@pre}/config/config.exs",              :web, "config/config.exs"},
    {:eex,  "#{@pre}/config/dev.exs",                 :web, "config/dev.exs"},
    {:eex,  "#{@pre}/config/prod.exs",                :web, "config/prod.exs"},
    {:eex,  "#{@pre}/config/prod.secret.exs",         :web, "config/prod.secret.exs"},
    {:eex,  "#{@pre}/config/test.exs",                :web, "config/test.exs"},
    {:eex,  "#{@pre}/lib/app_name.ex",                :web, "lib/:web_app.ex"},
    {:eex,  "#{@pre}/lib/app_name/application.ex",    :web, "lib/:web_app/application.ex"},
    {:eex,  "phx_web/channels/user_socket.ex",        :web, "lib/:web_app/channels/user_socket.ex"},
    {:keep, "phx_web/controllers",                    :web, "lib/:web_app/controllers"},
    {:eex,  "phx_web/endpoint.ex",                    :web, "lib/:web_app/endpoint.ex"},
    {:eex,  "phx_web/router.ex",                      :web, "lib/:web_app/router.ex"},
    {:eex,  "phx_web/views/error_helpers.ex",         :web, "lib/:web_app/views/error_helpers.ex"},
    {:eex,  "phx_web/views/error_view.ex",            :web, "lib/:web_app/views/error_view.ex"},
    {:eex,  "#{@pre}/mix.exs",                        :web, "mix.exs"},
    {:eex,  "#{@pre}/README.md",                      :web, "README.md"},
    {:keep, "phx_test/channels",                      :web, "test/:web_app/channels"},
    {:keep, "phx_test/controllers",                   :web, "test/:web_app/controllers"},
    {:eex,  "#{@pre}/test/test_helper.exs",           :web, "test/test_helper.exs"},
    {:eex,  "phx_test/support/channel_case.ex",       :web, "test/support/channel_case.ex"},
    {:eex,  "phx_test/support/conn_case.ex",          :web, "test/support/conn_case.ex"},
    {:eex,  "phx_test/views/error_view_test.exs",     :web, "test/:web_app/views/error_view_test.exs"},
  ]

  template :gettext, [
    {:eex,  "phx_gettext/gettext.ex",               :web, "lib/:web_app/gettext.ex"},
    {:eex,  "phx_gettext/en/LC_MESSAGES/errors.po", :web, "priv/gettext/en/LC_MESSAGES/errors.po"},
    {:eex,  "phx_gettext/errors.pot",               :web, "priv/gettext/errors.pot"}
  ]

  template :react, [
    {:text, "phx_assets/react/gitignore",        :web, ".gitignore"},
    {:eex,  "phx_assets/react/webpack.config.js", :web, "assets/webpack.config.js"},
    {:text, "phx_assets/app.css",                 :web, "assets/css/app.css"},
    {:text, "phx_assets/phoenix.css",             :web, "assets/css/phoenix.css"},
    {:eex,  "phx_assets/react/app.js",           :web, "assets/js/app.js"},
    {:eex,  "phx_assets/react/socket.js",        :web, "assets/js/socket.js"},
    {:eex,  "phx_assets/react/package.json",     :web, "assets/package.json"},
    {:text, "phx_assets/robots.txt",              :web, "assets/static/robots.txt"},
    {:keep, "phx_assets/vendor",                  :web, "assets/vendor"},
  ]

  template :html, [
    {:eex,  "phx_web/controllers/react_controller.ex",         :web, "lib/:web_app/controllers/react_controller.ex"},
    {:eex,  "phx_web/templates/layout/app.html.eex",          :web, "lib/:web_app/templates/layout/app.html.eex"},
    {:eex,  "phx_web/templates/react/index.html.eex",          :web, "lib/:web_app/templates/react/index.html.eex"},
    {:eex,  "phx_web/views/layout_view.ex",                   :web, "lib/:web_app/views/layout_view.ex"},
    {:eex,  "phx_web/views/react_view.ex",                     :web, "lib/:web_app/views/react_view.ex"},
    {:eex,  "phx_test/controllers/react_controller_test.exs",  :web, "test/:web_app/controllers/react_controller_test.exs"},
    {:eex,  "phx_test/views/layout_view_test.exs",            :web, "test/:web_app/views/layout_view_test.exs"},
    {:eex,  "phx_test/views/react_view_test.exs",              :web, "test/:web_app/views/react_view_test.exs"},
  ]

  template :bare, [
    {:text, "phx_assets/bare/gitignore", :web, ".gitignore"},
  ]

  template :static, [
    {:text,   "phx_assets/bare/gitignore", :web, ".gitignore"},
    {:text,   "phx_assets/app.css",        :web, "priv/static/css/app.css"},
    {:append, "phx_assets/phoenix.css",    :web, "priv/static/css/app.css"},
    {:text,   "phx_assets/bare/app.js",    :web, "priv/static/js/app.js"},
    {:text,   "phx_assets/robots.txt",     :web, "priv/static/robots.txt"},
  ]

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    project_path = Path.expand(project.base_path)

    %Project{project |
             in_umbrella?: true,
             project_path: project_path,
             web_path: project_path,
             web_app: app,
             web_namespace: project.app_mod}
  end

  def generate(%Project{} = project) do
    copy_from project, __MODULE__, :new
    copy_from project, __MODULE__, :gettext

    gen_html(project)
    gen_react(project)
    project
  end

  defp gen_html(%Project{} = project) do
    copy_from project, __MODULE__, :html
  end

  defp gen_react(%Project{web_path: web_path} = project) do
    copy_from project, __MODULE__, :react
    create_file Path.join(web_path, "assets/static/images/phoenix.png"), phoenix_png_text()
    create_file Path.join(web_path, "assets/static/favicon.ico"), phoenix_favicon_text()
  end
end
