import Config

config :logger, :console, level: :debug

config :logger, handle_otp_reports: false

config :rabbit_mq, :amqp_url, "amqp://guest:guest@localhost:5672"
