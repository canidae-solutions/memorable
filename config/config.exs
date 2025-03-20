import Config

config :mnesia,
  dir: ~c"db/#{config_env()}/#{node()}"

import_config "#{config_env()}.exs"
