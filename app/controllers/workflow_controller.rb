class WorkflowController < ApplicationController

  def index
    @workflow_messages = WorkflowMessage.all
  end

  def delete
    WorkflowMessage.destroy_all
    redirect_to workflow_path
  end

  def ajax_progress
    @workflow_messages = WorkflowMessage.all

    render partial: "working_queue"
  end
end
