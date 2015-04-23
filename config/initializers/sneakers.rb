require "sneakers"
require "sneakers/metrics/logging_metrics"
require_relative "../../lib/sneakers_maxretry_handler.rb"

# WORKERS=''
# WORKERS+=UploadPdfWorker,
# WORKERS+=RenderPdfWorker,
# WORKERS+=WorkflowInWorker,
# WORKERS+=WorkflowOutWorker
# export WORKERS
# rake sneakers:run

Sneakers.configure  heartbeat: 2,
                    amqp: "amqp://ubuntu:ubuntu@192.168.0.12:5672",
                    vhost: "test",
                    exchange: "sneakers",
                    exchange_type: "direct",
                    metrics: Sneakers::Metrics::LoggingMetrics.new,
                    daemonize: false,
                    start_worker_delay: 0.2,
                    workers: 4,
                    log:  STDOUT,
                    durable: true,
                    ack: true,
                    heartbeat_interval: 5,
                    handler: Sneakers::Handlers::Maxretry,
                    retry_max_times: 4,
                    retry_timeout:  15000
Sneakers.logger.level = Logger::INFO

