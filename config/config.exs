import Config

config :mnesia,
  dir: ~c"db/#{config_env()}/#{node()}"

if System.get_env("IS_NIX_BUILD") do
  config :memorable, Subprocess, skip_compilation?: true
end

import_config "#{config_env()}.exs"
