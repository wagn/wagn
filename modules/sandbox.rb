class Bucket  
  attr_accessor :value
end

class Sandbox
  attr_reader :securityViolationDetected,
    :securityViolationText, :syntaxErrorDetected,
    :syntaxErrorText, :sandboxOutput 
    
  def initialize(level = 2, request=nil, maxRunTime = 10,
    maxThreadCount = 10, maxNewObjects = 10000)
    @request = request
    @level = level
    @maxRunTime = maxRunTime
    @maxThreadCount = maxThreadCount
    @maxNewObjects = maxNewObjects

    @securityViolationDetected = false
    @securityViolationText = ""
    @syntaxErrorDetected = false
    @syntaxErrorText = ""
    @sandboxOutput = ""
    bucket = Bucket.new
    bucket.taint
     
    @sandboxOutput = bucket
    
    @sandboxThreadGroup = ThreadGroup.new
    Thread.abort_on_exception= true
    @done = false
  end 

  def threadCount
    return Thread.list.size
  end

  def raiseSecurityError(text)
    raise(SecurityError, text)
  end

  def starteWaechterThread
    @waechterThread = Thread.new {
    ObjectSpace.garbage_collect 
    anzObjAmAnfang = ObjectSpace.each_object {}
    runningForSecs = 0
    begin
      while not(@done) do
        if (runningForSecs > @maxRunTime) then
          raiseSecurityError("Your script may only
            run for #{@maxRunTime}sec")
        end
        ObjectSpace.garbage_collect 
        if ((ObjectSpace.each_object {} -
          anzObjAmAnfang) > @maxNewObjects) then
          raiseSecurityError("You may only create
            #{@maxNewObjects} objects")
        end
        if (threadCount > @maxThreadCount) then
          raiseSecurityError("You may only use
            #{@maxThreadCount} Threads")
        end
        sleep 1
        runningForSecs += 1
      end # while
    rescue SecurityError => detail
      @securityViolationDetected = true
      @securityViolationText = detail
      sleep 0.1
      @sandboxThreadGroup.list.each { | th |  
        th.kill
      }
      @done = true
    end
    } # end_of_thread
  end

  def starteInDerSandbox(exeCmd)
    begin 
      request = @request
      @sandboxOutput.value = eval(exeCmd, Object.module_eval("binding")) 
    rescue SecurityError => detail
      @securityViolationDetected = true
      @securityViolationText = detail
    rescue Exception => detail
      @syntaxErrorDetected = true
      @syntaxErrorText = detail
    end
  end

  def fuehreAus(cmd)
    cmd.untaint 
    exeCmd = cmd  
    
    exeCmd = "$SAFE = #{@level}\n" + exeCmd
    starteWaechterThread # this is our BIG BROTHER
    @sandboxThreadGroup.add(@sandboxThread =
      Thread.new {
      starteInDerSandbox(exeCmd)
    })
    @sandboxThread.priority= -5   # sehr niedrig!
    @sandboxThread.join   # wait for completion
    @done = true
    @waechterThread.join
  end
end # class Sandbox

