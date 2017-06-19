ExUnit.start()
<%= if ecto do %>
<%= adapter_config[:test_setup_all] %>
<% end %>

IO.puts "Compiling server-side JS"
webpack_bin = System.cwd! <> "/assets/node_modules/.bin/webpack"
{_, 0} = System.cmd(webpack_bin, [], cd: "assets")
IO.puts "Server-side JS compiled"
