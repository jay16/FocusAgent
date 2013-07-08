class WorkerController < ApplicationController
  def schedule
     Resque.reload_schedule! if Resque::Scheduler.dynamic

  end

  def requeue
    config = Resque.schedule[params['job_name']]
    Resque::Scheduler.enqueue_from_config(config)
   
    respond_to do |format| format.js end
  end
end
