class SmokeTestReceiver

  def initialize(delivery_info, properties, body)
    Rails.logger.debug "Received message #{body}"
    create_record(body)
  end

  private
  def create_record(body)
    SmokeTest.create(message: body)
  end
end
