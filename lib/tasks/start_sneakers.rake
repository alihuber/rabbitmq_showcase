namespace :rabbitmq do
  desc "Starts daemonized sneakers process"
  task start_sneakers: :environment do
    worker_classes = Rails.application.config_for(:worker)["worker_classes"]

    puts "Building string with class names of sneakers-workers..."
    worker_string = "WORKERS="
    worker_classes.each do |klass|
      puts "registering #{klass}"
      worker_string << "#{klass}"
    end
    puts

    puts "All done!"
    puts "Starting sneakers with given worker classes..."

    sh "#{worker_string} rake sneakers:run"
  end
end
