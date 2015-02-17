local bs_session = require "bs_session"

-- get name
ngx.req.read_body()
local post_args, err = ngx.req.get_post_args()
local lr_email
if post_args then
	local k, v
	for k ,v in pairs(post_args) do
		if k == "lr_lemail" then
			lr_email = v
		end
	end
end
if not lr_email then
	ngx.log("NO post body")
	ngx.exit(500)
end



-- check name, and set Cookie
local sessionL = bs_session:new()

local res = sessionL.wrapdb:select("uic","name,uid",{email=lr_email})

if not res then
	ngx.log(ngx.ERR, "user not registered")
	return ngx.exit(500)
else
	local row, name, uid
	for _, row in ipairs(res) do
		name = row.name
		uid = row.uid
	end

	if not name then
		local refer = ngx.req.get_headers()['Referer']
		local _,d = string.match(refer,"(again=)(%d)")
		if d then
			refer = string.gsub(refer, "again=%d", "again="..(d+1))
		else
			refer = refer..'&again=1'
		end
		ngx.redirect(refer)
--		ngx.redirect(ngx.req.get_headers()['Referer']..'&again=1')
	else
		local time, err = sessionL:updateLoginTime(name,uid)
		if not time then
			ngx.log(ngx.ERR, err)
			ngx.exit(500)
		end
		
	--	local times = os.date("%Y-%m-%d %H:%M:%S", time)
		local str = "name="..name.."&time="..time
		local user_cookie = sessionL:xxencode(str)
		ngx.header['Set-Cookie'] = {'DS_USER_cookie='..user_cookie..'; path=/'}
		local backurl = ngx.var.arg_backurl
		ngx.redirect(backurl)
	end
end


