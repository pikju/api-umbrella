local csrf = require "api-umbrella.web-app.utils.csrf"

local _M = {}

function _M.new()
end

function _M.create()
end

function _M.show()
end

return function(app)
  app:get("/admins/unlock/new(.:format)", _M.new)
  app:post("/admins/unlock(.:format)", csrf.validate_token_filter(_M.create))
  app:get("/admins/unlock(.:format)", _M.show)
end
