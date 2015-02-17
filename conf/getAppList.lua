local bs_upsql = require "bs_upsql"
local wrapdb = bs_upsql:new("binshared")
if not wrapdb then
	ngx.log(ngx.ERR, "can't connect to DB")
	return ngx.exit(500)
end

local res = wrapdb:select("applist", _, _, "order by pv desc")
if not res then
	ngx.log(ngx.ERR, "select applist error")
	return ngx.exit(500)
end


local bs_htbuild = require "bs_htbuild"

for order, row in ipairs(res) do
	local fattris = {style="font-size: large;padding-top: 5px;"}
	local cells = {nums=3, allot={2, 6, 4}}
	local btbuilder = bs_htbuild:newbt(cells, fattris)
	if btbuilder == nil then
		ngx.say("new btbuilder errror")
	end


	local elpaint = bs_htbuild.elpaint
	
	local attris = {class="text-center"}
	local str1 = elpaint(self,"p",attris,order)
	
	local str2 = elpaint(self,_,{},row.descri)
	
	local str3 = elpaint(self,_,attris,"pv: "..row.pv..",  ex: "..row.doit)

	attris = {
		href = "/"..row.appname.."/"..row.page,
		target = "_blank"
	}
	local str4 = elpaint(self,"a",attris,str3)


	btbuilder:setcattris(3,"style","background-color: antiquewhite;")
	btbuilder:setcattris(1,"style","color: red;background-color: aliceblue;")
	btbuilder:setcattris(2,"style","background-color: aquamarine;")
	local res = btbuilder:paint(str1, str2, str4)
	ngx.say(res)
end


local ok, err = wrapdb.db:set_keepalive(10000, 50)
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    ngx.exit(500)
end
