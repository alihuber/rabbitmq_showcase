require "sneakers"
require "sneakers/metrics/logging_metrics"
require_relative "../../lib/sneakers_maxretry_handler.rb"

Sneakers.configure  heartbeat: 2000,
                    amqp: "amqp://ubuntu:ubuntu@192.168.0.12:5672",
                    vhost: "test",
                    metrics: Sneakers::Metrics::LoggingMetrics.new,
                    daemonize: false,
                    heartbeat_interval: 2000,
                    start_worker_delay: 0.2,
                    durable: true,
                    ack: true,
                    workers: 5,
                    retry_timeout: 30000,
                    retry_max_times: 3,
                    timeout_job_after: 60,
                    threads: 4,
                    prefetch: 4,
                    log: STDOUT
Sneakers.logger.level = Logger::INFO
