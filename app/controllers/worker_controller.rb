class WorkerController < ApplicationController
  def schedule
     Resque.reload_schedule! if Resque::Scheduler.dynamic

  end

  def requeue
    config = Resque.schedule[params['job_name']]
    Resque::Scheduler.enqueue_from_config(config)
   
    respond_to do |format| format.js end
  end
 
  #stop a worker by pid
  def stop
    pid = params[:pid]
    system("kill -9 #{pid}")
    #Resque.dequeue(MV_Worker,"other")
    #Resque.remove_queue("MV_Worker")
    #pids = Array.new
    #Resque.workers.each do |worker|
    #  pids << worker.worker_pids
    #end
    #if pids.size > 0
    #   system("kill -s -QUIT #{pids.join(' ')}")
    #end

    respond_to do |format| format.js end
  end
end
