import Config

# Include all metadata in development logs
config :logger, :console, metadata: [:file, :line, :pid]
