module NumbericMethods
  def self.included(base)
    base.class_eval do
      [:duration].each do |method_name|
        next unless method_defined?(method_name)
        location = self.method(method_name).source_location rescue next
        next if location[0] == __FILE__

        warn "\tRemove Method - #{method_name} defiend in:\n%s\nand reload file in \n%s" % [location, __FILE__]
        remove_method method_name
      end
    end
  end
  def duration
      steps=[60, 60, 24, 365,0]
      names=[:seconds, :minutes, :hours, :days, :years]
      results=[]
      stepper = self.to_int.abs
      steps.each do |div|
          if stepper > 0
              if div > 0
                  results << stepper % div
                  stepper/=div
              else
                  results << stepper
              end
          end
      end
      e  = results.empty? ? 0 : results.count - 1
      mt = e > 0 ? results[e-1] : 0
      et = results[e] || 0

      et.to_s+" "+names[e].to_s + (mt>0 ? " "+mt.to_s+" "+names[e-1].to_s : '')
  end
  def duration_with_format(options)
  end
end
class Numberic
  include NumbericMethods
end
class Fixnum
  include NumbericMethods
end
