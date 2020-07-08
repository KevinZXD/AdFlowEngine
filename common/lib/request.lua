---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:33 PM
---

-----------------------------------------------------------------------------
-- 获取并组装请求里面的参数信息
--
-----------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------
-- 检查参数里面的各个字段格式是否正常
-- 如果格式有错误，则将其赋值为空串
-- Input
-- @param args 参数table
-- Returns
-- @return args 检查之后的args
-----------------------------------------------------------------------------
function check(args)
    local int_keys = {
        'uid',
        'from',
        'proxy_source',
        'list_id',
        'max_id',
        'last_span',
        'unread_status',
        'from_p',
        'trend_version',
    }
    for _, k in ipairs(int_keys) do
        if args[k] and not string.match(args[k], '^[-0-9]+$') then
            args[k] = ''
        end
    end

    if args['posid'] and not string.match(args['posid'], '^pos[0-9a-zA-Z]+$') then
        args['posid'] = ''
    end

    if args['wm'] and not string.match(args['wm'], '^[0-9_]+$') then
        args['wm'] = ''
    end

    if args['ip'] and not string.match(args['ip'], '^[0-9.]$') then
        args['ip'] = ''
    end

    if args['lang'] and not string.match(args['lang'], '^[a-zA-Z0-9_-]+$') then
        args['lang'] = ''
    end

    return args
end

-----------------------------------------------------------------------------
-- 初始化方法
-- 封装requst请求携带的get参数、post参数、用户自定义参数、请求发生时间等
-- Input
-- @param self 自身对象
-- Returns
-- @return 封装好的requst数据对象
-----------------------------------------------------------------------------
function new(self)

    ngx.req.read_body()
    local _start_time = ngx.req.start_time() --请求创建时的时间戳，浮点数，格式为：秒.毫秒

    local cjson = require('cjson')
    local post_params = ngx.req.get_body_data()
    local status
    status, post_params = pcall(cjson.decode, post_params)

    return setmetatable({
        get_args = ngx.req.get_uri_args(), -- table
        post_args = post_params,  -- table
        start_time = _start_time,
        start_time_s = math.floor(_start_time),
        start_time_str = os.date('%Y-%m-%d %H:%M:%S', _start_time),
        customized_args = {},
        global_args = {},
    }, {
        __index = self,
        __tostring = function(t)
            local _tmp = {}
            for k, v in pairs(t.customized_args) do
                _tmp[k] = v
            end
            for k, v in pairs(t.post_args) do
                if not _tmp[k] then
                    _tmp[k] = v
                end
            end

            for k, v in pairs(t.get_args) do
                if not _tmp[k] then
                    _tmp[k] = v
                end
            end
            return ngx.encode_args(_tmp)
        end
    })
end

-----------------------------------------------------------------------------
-- 从参数里面根据key获取value值
-- 包括post参数，get参数和用于自定参数
-- Input
-- @param key 参数key
-- @param default 若key对应的value为空时的默认值
-- Returns
-- @return v key对应的参数值
-----------------------------------------------------------------------------
function get(self, key, default)

    local v = self.post_args[key] or self.get_args[key] or self.customized_args[key] or nil
    if not v and default then
        return default
    end

    if type(v) == 'table' and #v > 0 then
        v = v[1]
    end

    return v
end

-----------------------------------------------------------------------------
-- 从get请求参数里面根据key获取值
-- Input
-- @param key 参数key
-- Returns
-- @return v key对应的参数值
-----------------------------------------------------------------------------
function get_get(self, key)
    return self.get_args[key] or nil
end

-----------------------------------------------------------------------------
-- 从post请求参数里面根据key获取值
-- Input
-- @param key 参数key
-- Returns
-- @return v key对应的参数值
-----------------------------------------------------------------------------
function get_post(self, key)
    return self.post_args[key] or nil
end



