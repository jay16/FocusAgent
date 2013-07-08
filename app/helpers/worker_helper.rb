module WorkerHelper 
  def format_time(t)
    t.strftime("%Y-%m-%d %H:%M:%S %z")
  end

  def queue_from_class_name(class_name)
    Resque.queue_from_class(Resque.constantize(class_name))
  end

  def failed_multiple_queues?
    return @multiple_failed_queues if defined?(@multiple_failed_queues)
    @multiple_failed_queues = Resque::Failure.queues.size > 1
  end
end
