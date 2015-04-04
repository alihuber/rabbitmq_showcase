class TopicController < ApplicationController

  def index
    get_records
  end

  def delete
    Topic.destroy_all
    redirect_to topic_path
  end

  def ajax_progress
    get_records

    render partial: "working_queue"
  end


  private

  def get_records
    @debugger_topics = Topic.where("routing_key LIKE ?", "%debug.%")
    @info_topics     = Topic.where("routing_key LIKE ?", "%.info%" )
    @logger_topics   = Topic.where("routing_key LIKE ?", "%logger.%")
  end
end
