class WorkflowController < ApplicationController

  def index
    @workflow_messages = WorkflowMessage.all
    render stream: true
  end

  def delete
    WorkflowMessage.destroy_all
    redirect_to workflow_path
  end

  def ajax_progress
    set_working_queue

    render partial: "working_queue"
  end


  private

  def set_working_queue
    @workflow_messages = WorkflowMessage.all
  end
end
