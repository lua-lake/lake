describe('core.JobQueue', function()
  local JobQueue = require 'core.JobQueue'

  local mach = require 'deps/mach'

  local pending
  local mocks
  local jobs

  local function Job(i)
    mocks[i] = mach.mock_function(tostring(i))
    return function()
      mocks[i]()
      pending[i] = coroutine.running()
      coroutine.yield()
    end
  end

  local function complete_job(i)
    coroutine.resume(pending[i])
  end

  before_each(function()
    pending = {}
    mocks = {}
    jobs = {}
    for i = 1, 5 do
      table.insert(jobs, Job(i))
    end
  end)

  it('should run jobs in FIFO order', function()
    local job_queue = JobQueue(3)

    mocks[1]:should_be_called():
      and_then(mocks[2]:should_be_called()):
      and_then(mocks[3]:should_be_called()):
      and_then(mocks[4]:should_be_called()):
      and_then(mocks[5]:should_be_called()):
      when(function()
        for i = 1, 5 do
          job_queue.schedule(jobs[i])
        end
        for i = 1, 5 do
          complete_job(i)
        end
      end)
  end)

  it('should limit the number of concurrent jobs to the maximum specified', function()
    local job_queue = JobQueue(2)

    mocks[1]:should_be_called():
      and_then(mocks[2]:should_be_called()):
      when(function()
        for i = 1, 5 do
          job_queue.schedule(jobs[i])
        end
      end)

    mocks[3]:should_be_called():
      when(function()
        complete_job(2)
      end)

    mocks[4]:should_be_called():
      when(function()
        complete_job(3)
      end)

    mocks[5]:should_be_called():
      when(function()
        complete_job(1)
      end)
  end)

  it('should allow jobs to be added once execution has begun', function()
    local job_queue = JobQueue(2)

    mocks[1]:should_be_called():
      and_then(mocks[2]:should_be_called()):
      when(function()
        job_queue.schedule(jobs[1])
        job_queue.schedule(jobs[2])
        job_queue.schedule(jobs[3])
        job_queue.schedule(jobs[4])
      end)

    mocks[3]:should_be_called():
      when(function()
        complete_job(2)
      end)

    job_queue.schedule(jobs[5], true)

    mocks[4]:should_be_called():
      when(function()
        complete_job(3)
      end)

    mocks[5]:should_be_called():
      when(function()
        complete_job(1)
      end)
  end)
end)
