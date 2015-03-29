require "sneakers"
require "sneakers/metrics/logging_metrics"

Sneakers.configure  heartbeat: 2000,
                    amqp: "amqp://ubuntu:ubuntu@192.168.0.12:5672",
                    vhost: "test",
                    exchange: "sneakers",
                    exchange_type: :direct,
                    runner_config_file: nil,     # A configuration file (see below)
                    metrics: Sneakers::Metrics::LoggingMetrics.new,
                    daemonize: false,         # Send to background
                    start_worker_delay: 0.2,  # When workers do frenzy-die, randomize to avoid resource starvation
                    workers: 5,               # Number of per-cpu processes to run
                    log: STDOUT
