class WorkerController < ApplicationController

  def index
    @worker_messages = WorkerMessage.all
  end

  def delete
    WorkerMessage.destroy_all
    redirect_to worker_path
  end

  def ajax_progress
    @worker_messages = WorkerMessage.all

    render partial: "working_queue"
  end
end
