
local bs_upsql = require "bs_upsql"
local appTable = "applist"

local _M = { _VERSION = '0.0.1' }

-- TODO:
-- 	MYSQL mutex

function _M:incVisit(app, param)

	local wrapdb = bs_upsql:new("binshared")
	if not wrapdb then
		ngx.log(ngx.ERR, "can't connect to DB")
		return ngx.exit(500)
	end

	local res = wrapdb:select(appTable,param,{appname=app})
	if not res then
		ngx.log(ngx.ERR, string.format("select %s.%s error",app,param))
		return ngx.exit(500)
	end

	local newV = res[1][param] + 1
	local set = {}
	set[param] = newV
	res = wrapdb:update("applist",set,{appname=app})
	if not res then
		ngx.log(ngx.ERR, string.format("set %s.%s error",app,param))
		return ngx.exit(500)
	end

end

return _M
