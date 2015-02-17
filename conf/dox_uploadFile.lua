local OPENtoTHESE = "MANG"
local BACK_STRING
	--LOGOUT
	--DENY
	--ERROR
	--SUCCESS

local cjson = require "cjson"
local mysql = require "resty.mysql"


local upload = require "resty.upload"
local cjson = require "cjson"

local form = upload:new(1024)
form:set_timeout(1000) -- 1 sec

-- check allow
local bs_session = require "bs_session"
local sessionL = bs_session:new()
local flag, username = sessionL:checkLogin()
local db = sessionL.wrapdb

if flag == 1 or flag == 2 then
--	您还未登录，或者session已过期，请刷新页面重新登录
	BACK_STRING = "LOGOUT"..flag
elseif flag == 0 and not string.find(OPENtoTHESE, username) then
	BACK_STRING = "DENY"
	local up = require("bs_updateAppVisit")
	up:incVisit("dox","doit")
else
	-- flag = 0 and user ALLOWED
	local up = require("bs_updateAppVisit")
	up:incVisit("dox","doit")

	local baseDIR = "/home/zmkeil/dirOfShared/doxfile/"
	local fcount = 0
	local filest = {}
	local filename = nil

	local function recordInDB(db, filename, username)
		local time = ngx.time()
		local url = "/doxfile/"..filename
		local res = db:insert("dox",{username,filename,time,url})
		if not res then
			return nil, "insert dox_table error"
		end

		return "ok"
	end

	while true do
		local typ, res, err = form:read()
		if not typ then
			ngx.say("failed to read: ", err)
			return
		end

		if typ == "header" then
			local str = res[2]
			local k, v
			for k, v in string.gmatch(str, "(%a+)%s*=%s*\"([^;]+)\"") do
				filest[k] = v
				--			ngx.say(k..": "..v.."\n")
			end

		end

		if typ == "body" then
			if not filename then
				if filest.filename then
					filename = filest.filename
					io.output(baseDIR..filename, 'w')
					io.write(res)
				end
			else
				io.write(res)
			end
		end

		if typ == "part_end" and filename then
			io.flush()
			io.close()

			local ok, err = recordInDB(db,filename,username)
			if not ok then
				ngx.log(ngx.ERR, err)
				BACK_STRING = "ERROR: "..err
				break
			end

			filename = nil
			filest = {}
		end

		if typ == "eof" then
			BACK_STRING = "SUCCESS"
			break
		end
	end

end

-- notice, ajaxfileupload.js is corrected
ngx.req.set_header('Content-Type', "json")
local rt = {}
rt.msg = BACK_STRING
ngx.say(cjson.encode(rt))

