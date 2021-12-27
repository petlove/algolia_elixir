import Config

config :tesla, adapter: {Tesla.Adapter.Hackney, [path_encode_fun: &URI.encode/1]}

import_config "#{config_env()}.exs"
