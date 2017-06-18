defmodule <%= app_module %>.Web do
  @moduledoc """
  A module defining __using__ hooks for controllers,
  views and so on.

  This can be used in your application as:

      use <%= app_module %>.Web, :controller
      use <%= app_module %>.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """
<%= if ecto do %>
  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query<%= if adapter_config[:binary_id] do %>

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id<% end %>
    end
  end
<% else %>
  def model do
    quote do
      # Define common model functionality
    end
  end
<% end %>
  def controller do
    quote do
      use Phoenix.Controller<%= if namespaced? do %>, namespace: <%= app_module %><% end %>
<%= if ecto do %>
      alias <%= app_module %>.Repo
      import Ecto
      import Ecto.Query
<% end %>
      import <%= app_module %>.Router.Helpers
      import <%= app_module %>.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"<%= if namespaced? do %>, namespace: <%= app_module %><% end %>

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]<%= if html do %>

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML<% end %>

      import <%= app_module %>.Router.Helpers
      import <%= app_module %>.ErrorHelpers
      import <%= app_module %>.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel<%= if ecto do %>

      alias <%= app_module %>.Repo
      import Ecto
      import Ecto.Query<% end %>
      import <%= app_module %>.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
