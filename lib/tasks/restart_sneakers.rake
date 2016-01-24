namespace :rabbitmq do
  desc "Restarts daemonized sneakers processes"
  task :restart_sneakers, [:pid] => [:environment] do |t, args|
    sh "rake rabbitmq:stop_sneakers[#{args.pid}]"
    sh "rake rabbitmq:start_sneakers"
  end
end
