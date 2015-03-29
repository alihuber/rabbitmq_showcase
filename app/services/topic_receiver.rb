class TopicReceiver

  def initialize(routing_key, body)
    Rails.logger.debug "Received topic #{routing_key}: #{body}"
    create_record(routing_key, body)
  end

  private
  def create_record(routing_key, body)
    # wait until others are inserted
    sleep Random.new.rand(2.0)
    existing_message =
      Topic.where("routing_key = ? AND message = ?", routing_key, body)
    unless existing_message.any?
      Topic.create(routing_key: routing_key, message: body)
    end
  end
end
