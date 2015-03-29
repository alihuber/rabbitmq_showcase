class WorkerReceiver

  def initialize(delivery_info, properties, body)
    Rails.logger.debug "Received message #{body}"
    work_time = properties.type
    create_record(body, work_time)
  end

  private
  def create_record(body, time)
    WorkerMessage.create(message: body, work_time: time)
  end
end
