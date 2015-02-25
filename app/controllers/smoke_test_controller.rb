class SmokeTestController < ApplicationController

  def index
    @smoke_tests = SmokeTest.all
    render stream: true
  end

  def destroy
    SmokeTest.destroy_all
    render "index"
  end
end

