return function(max_concurrent)
  local jobs = {}
  local head = 1
  local tail = 1
  local count = 0
  local running = 0

  local execute_job

  local function job_finished()
    running = running - 1
    if count > 0 then
      local next = jobs[head]
      head = head + 1
      count = count - 1
      execute_job(next)
    end
  end

  execute_job = function(job)
    coroutine.wrap(function()
      job()
      job_finished()
    end)()
  end

  return {
    schedule = function(job)
      if running < max_concurrent then
        running = running + 1
        execute_job(job)
      else
        jobs[tail] = job
        tail = tail + 1
        count = count + 1
      end
    end
  }
end
