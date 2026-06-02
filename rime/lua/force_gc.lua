local function force_gc()
  collectgarbage("step")
end

return force_gc
