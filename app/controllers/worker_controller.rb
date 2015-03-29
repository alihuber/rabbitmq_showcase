class WorkerController < ApplicationController

  def index
    @worker_messages = WorkerMessage.all
    render stream: true
  end

  def delete
    WorkerMessage.destroy_all
    redirect_to worker_path
  end

  def ajax_progress
    set_working_queue

    render partial: "working_queue"
  end


  private

  def set_working_queue
    @worker_messages = WorkerMessage.all
  end
end

