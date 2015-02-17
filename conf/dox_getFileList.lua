local OPENtoTHESE = "MANG"

local bs_htbuild = require "bs_htbuild"
local elpaint = bs_htbuild.elpaint

-- check allow
local bs_session = require "bs_session"
local sessionL = bs_session:new()
local flag, username = sessionL:checkLogin()
local db = sessionL.wrapdb



-- app content
local function paintOneFile(filename, updatetime, fileurl, backurl)
	local at2 = {href = "javascript:dox_showUrl(\'"..filename.."\',\'"..fileurl.."\')"}
	local td = elpaint(self,"label",{},os.date("%Y-%m-%d %H:%M:%S", updatetime))
	td = td.."&nbsp;&nbsp;&nbsp"..elpaint(self,"a",at2,filename)
	res = elpaint(self,"p",_,td)
	return res
end

local function allfiles(db, backurl)
	local result = ""
	local nums = 0
	local res = db:select("dox",_,{user_name=username},"order by updatetime")
	if not res then
		ngx.log(ngx.ERR, "query dox_table error")
		return ngx.exit(500)
	else
		local row, filename, updatetime, fileurl
		for _, row in ipairs(res) do
			filename = row.filename
			updatetime = row.updatetime
			fileurl = row.url
			result = result..paintOneFile(filename, updatetime, fileurl, backurl)
			nums = nums + 1
		end
	end

	local rresult
	if nums == 0 then
		rresult = "You Have Not upload files"
	else
		rresult = elpaint(self,"div",{style="height: 320px; overflow: scroll;"},result)
	end
	
	return rresult.."<br/>"..elpaint(self,"input",{type="button",onclick="dox_reflash_flist();",value="Reflash"},"")
end



local str
local res
local backurl = ngx.var.arg_backurl
if flag == 1 then
	str = "请先登录"
elseif flag == 2 then
	str = "您离开太久了，请重新登录"
elseif flag == 0 then 
	if not string.find(OPENtoTHESE, username) then
		str = elpaint(self,"p",_,"该服务目前只对少数用户可用，如果您确实希望使用，请联系管理员")
		str = str..elpaint(self,"p",_,"zhaomangzheng@163.com")
	else
		str = allfiles(db, backurl)
	end
else
	str = elpaint(self,"p",_,"server error")
end

if flag ~= 0 then
	res = "<a href=\"/login.html?backurl="..backurl.."\">"..str.."</a>"
else
	res = str
end

ngx.say(res)
