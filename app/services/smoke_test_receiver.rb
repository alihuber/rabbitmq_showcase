class SmokeTestReceiver

  def initialize(delivery_info, properties, body)
    puts "Received #{delivery_info} #{properties} #{body}"
  end
end
