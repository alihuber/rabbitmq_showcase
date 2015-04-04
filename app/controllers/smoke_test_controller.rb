class SmokeTestController < ApplicationController

  def index
    @smoke_tests = SmokeTest.all
  end

  def delete
    SmokeTest.destroy_all
    redirect_to root_path
  end

  def ajax_progress
    @smoke_tests = SmokeTest.all

    render partial: "working_queue"
  end
end
