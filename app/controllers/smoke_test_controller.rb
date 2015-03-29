class SmokeTestController < ApplicationController

  def index
    @smoke_tests = SmokeTest.all
    render stream: true
  end

  def delete
    SmokeTest.destroy_all
    redirect_to root_path
  end

  def ajax_progress
    set_working_queue

    render partial: "working_queue"
  end


  private

  def set_working_queue
    @smoke_tests = SmokeTest.all
  end
end
