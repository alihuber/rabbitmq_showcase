namespace :rabbitmq do
  desc "Closes unneeded rabbitmq connections"
  task close_rabbitmq_connections: :environment do
    connect_command =
      "/usr/local/bin/rabbitmqadmin "\
      "#{Rails.application.secrets.rabbitmq['cli_args']}"

    connection_names = `#{connect_command} list connections name`
    begin
      connection_names = connection_names.gsub("|", "").split("\n")[3...-1].uniq
      connection_names.map(&:strip!)
      connection_names.delete("")
      connection_names.each do |name|
        puts "Closing connection #{name}"
        `#{connect_command} close connection name='#{name}'`
      end
    rescue NoMethodError
      puts "No connections present!"
    end
  end
end
