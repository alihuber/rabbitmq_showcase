class TopicController < ApplicationController

  def index
    @debugger_topics = Topic.where("routing_key LIKE ?", "%debug.%")
    @info_topics     = Topic.where("routing_key LIKE ?", "%.info%" )
    @logger_topics   = Topic.where("routing_key LIKE ?", "%logger.%")
    render stream: true
  end

  def delete
    Topic.destroy_all
    redirect_to topic_path
  end

  def ajax_progress
    set_working_queue

    render partial: "working_queue"
  end


  private

  def set_working_queue
    @debugger_topics = Topic.where("routing_key LIKE ?", "%debug.%")
    @info_topics     = Topic.where("routing_key LIKE ?", "%.info%" )
    @logger_topics   = Topic.where("routing_key LIKE ?", "%logger.%")
  end
end

