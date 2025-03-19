import Config
import_config "#{config_env()}.exs"

config :mnesia,
  dir: ~c"db/#{config_env()}/#{node()}"
