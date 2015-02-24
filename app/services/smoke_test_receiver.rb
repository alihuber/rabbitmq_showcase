class SmokeTestReceiver

  def initialize(delivery_info, properties, body)
    # create_record(body)
    puts body
  end

  private
  def create_record(body)
    SmokeTest.create(message: body)
  end
end
