-- perf
local StrUtil = require('lua.bdlib.String')
local str_find = string.find
local str_sub = string.sub
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

function Request:new()
    ngx.req.read_body()
    local params = ngx.req.get_uri_args()
    for k,v in pairs(ngx.req.get_post_args()) do
        params[k] = v
    end

    local instance = {
        uri = ngx.var.uri,
        req_uri = ngx.var.request_uri,
        req_args = ngx.var.args,
        params = params,
        uri_args = ngx.req.get_uri_args(),
        method = ngx.req.get_method(),
        headers = ngx.req.get_headers(),
        body_raw = ngx.req.get_body_data()
    }
    if instance.method == 'POST' then
        if instance.body_raw ~= nil then
            instance.arr_post = Request:phrasePostData(instance.body_raw)
        else
            instance.arr_post = {}
        end
    end
    setmetatable(instance, {__index = self})
    return instance
end

function Request:getControllerName()
    return self.controller_name
end

function Request:getActionName()
    return self.action_name
end

function Request:getHeaders()
    return self.headers
end

function Request:getHeader(key)
    if self.headers[key] ~= nil then
        return self.headers[key]
    else
        return false
    end
end

function Request:getParams()
    return self.params
end

function Request:getParam(key)
    return self.params[key]
end

function Request:setParam(key, value)
    self.params[key] = value
end

function Request:getMethod()
    return self.method
end

function Request:isGet()
    if self.method == 'GET' then return true else return false end
end

function Request:phrasePostData(dataStr)
    local arr = {}
    for _, kv_pairs in ipairs(StrUtil:explode(ngx.unescape_uri(dataStr), '&')) do
        kv_pairs = ngx.unescape_uri(kv_pairs)
        local s, e = str_find(kv_pairs, '=')
        if s then
            k = str_sub(kv_pairs, 1, s - 1)
            v = str_sub(kv_pairs, e + 1)
            arr[k] = v
        end
    end
    return arr
end

return Request
