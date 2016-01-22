workers     Integer(ENV["WEB_CONCURRENCY"] || 3)
threads     1, Integer(ENV["MAX_THREADS"] || 16)
environment ENV["RACK_ENV"] || "development"
port        ENV['PORT'] || 3000
rackup      DefaultRackup

preload_app!

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
