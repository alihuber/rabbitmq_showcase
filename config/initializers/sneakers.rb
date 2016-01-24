require "sneakers"
require "sneakers/metrics/logging_metrics"
require_relative "../../lib/sneakers_maxretry_handler.rb"

Sneakers.configure  heartbeat: 2,
                    amqp: Rails.application.secrets.rabbitmq["amqp_url"],
                    vhost: Rails.application.secrets.rabbitmq["vhost"],
                    env: Rails.env,
                    exchange: "sneakers",
                    exchange_type: "direct",
                    # metrics: Sneakers::Metrics::LoggingMetrics.new,
                    daemonize: true,
                    start_worker_delay: 0.2,
                    # per-cpu processes
                    workers: 4,
                    # threadpool size, should match prefetch
                    threads: 4,
                    prefetch: 4,
                    log: "#{Rails.root}/log/sneakers.log",
                    pid_path: "#{Rails.root}/sneakers.pid",
                    durable: true,
                    ack: true,
                    heartbeat_interval: 5,
                    handler: Sneakers::Handlers::Maxretry,
                    retry_timeout:  20000,
                    retry_max_times: 3,
                    hooks: {
                        before_fork: -> {
                            Rails.logger.info(
                              "Worker: Disconnect from the database")
                            ActiveRecord::Base.connection_pool.disconnect!
                        },
                        after_fork: -> {
                          config =
                            Rails
                            .application
                            .config
                            .database_configuration[Rails.env]
                          ActiveRecord::Base.establish_connection(config)
                          Rails.logger.info(
                            "Worker: Reconnect to the database")
                        }
                    }
Sneakers.logger.level = Logger::INFO
