-- Copyright (C) by Kwanhur Huang



local modulename = 'errorHandler'

local _M = { _VERSION = '0.01' }

local ERRORINFO = require('relay.error.errcode').info

_M.handler = function(errinfo)
    local info 
    if type(errinfo) == 'table' then
        info = errinfo
    elseif type(errinfo) == 'string' then
        info = {ERRORINFO.LUA_RUNTIME_ERROR, errinfo}
    else
        info = {ERRORINFO.BLANK_INFO_ERROR, }
    end
    
    local errstack = debug.traceback()
    return {info, errstack}
end

return _M
