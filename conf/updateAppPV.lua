
local up = require "bs_updateAppVisit"

local app = ngx.var.arg_app

up:incVisit(app, "pv")
