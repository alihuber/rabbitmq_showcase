namespace :rabbitmq do
  desc "Stops daemonized sneakers processes"
  task :stop_sneakers, [:pid] => [:environment] do |t, args|
    # run locally
    unless args.pid
      pid = ""
      begin
        pid = Rails.root.join("sneakers.pid").read.strip
        puts "read in PID: #{pid}"
      rescue
        # no such file, do nothing
      end
      unless pid.blank?
        process = `ps #{pid}`
        if process.include?("sneakers")
          puts "Sending SIGTERM to sneakers process with id #{pid}"
          puts
          sh "kill -SIGTERM #{pid}"
        else
          puts "No sneakers-process with #{pid} found"
        end
      end
    else
      puts "Sending SIGTERM to sneakers process with id #{args.pid}"
      puts
      sh "kill -SIGTERM #{args.pid}"
    end
  end
end
