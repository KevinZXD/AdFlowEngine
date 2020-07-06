---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:31 PM
---

-----------------------------------------------------------------------------
-- 调度处理程序，并行调用一次请求中对各个产品线的请求
-- request请求里面请求数据里面的response->data里面可能有多个数组，每个数组代表对一个业务线的请求
-- 在使用本模块之前已经组合好了业务线和其中的数据，在本调度程序里面并行调用
--
-----------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------
-- 初始化方法
-- 默认调用./scheduler/default.lua，该文件相当于该文件夹下其他类的父类
-- Input
-- @param core 传入调用者自身对象
-- Returns
-- @return 返回调用者自身对象，自身对象中此模块封装的各项数据
-----------------------------------------------------------------------------
function init(core)
    local  c = core.service_conf.scheduler
    if not c or c == '' then
        c = 'trends.scheduler.default'
    end
    local t = require(c)
    return t:new(core)
end

-----------------------------------------------------------------------------
-- 处理各模块
-- 并行执行多个子请求，来处理请求request data中对多个产品线模块的请求
-- Input
-- @param self 传入调用者自身对象
-- Returns
-- @return
-----------------------------------------------------------------------------
function process_modules(self)
    local reqs = {}
    for _, mo in ipairs(self.modules) do
        local _method, _uri, _body = mo:get_req_params()
        local method = 'GET'
        if _method == ngx.HTTP_POST then
            --TODO change to configurable Content-Type
            ngx.req.set_header('Content-Type', 'application/x-www-form-urlencoded')
            method = 'POST'
        elseif _method == ngx.HTTP_GET then
            method = 'GET'
        else
            method = 'UNKNOWN'
        end
        if ngx.HTTP_POST == _method then
            table.insert(reqs, {_uri, {method=_method, body=_body}})
        else
            table.insert(reqs, {_uri})
        end
    end

    local resps = {}
    if #reqs~=0 then
        resps = {ngx.location.capture_multi(reqs) }

    end
    if #resps == #reqs and #resps~=0 then
        for _i, mo in ipairs(self.modules) do -- 循环处理各各产品线

            mo:run(resps[_i]) -- 执行每个产品线里面的run方法，将返回结果数据整理放在data里
        end
    else
        ngx.log(ngx.ERR, 'scheduler error capture')
    end

end