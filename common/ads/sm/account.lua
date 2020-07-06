---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:38 PM
---

-----------------------------------------------------------------------------
-- 账号相关的service module处理文件
--
-----------------------------------------------------------------------------

module(..., package.seeall)
local name = ...

-----------------------------------------------------------------------------
-- 初始化方法，默认继承'trends.module'作为父类
-- Input
-- @param self 调用者自身self
-- @param smid service module的名称，如account、appllo、superfans等
-- @param core core数据
-- Returns
-- @return 生成的对象
-----------------------------------------------------------------------------
function new(self, smid, core)
    local parent = require('trends.module')
    setmetatable(self, {__index=parent})
    local m = {id = smid, name = name, core = core}
    return setmetatable(m, {__index=self})
end

-----------------------------------------------------------------------------
-- 控制方法，判断是否限制这个请求执行
-- 提供给sm目录下各server module判断是否处理该请求
-- 如果在组装数据时，这个模块对应的请求data里的数据为空，则不执行对请求的响应
-- Input
-- @param self 调用者自身self
-- Returns
-- @return limit boolean值，true代表限制，false代表不限制
-----------------------------------------------------------------------------
function ctrl(self)
    local limited = false
    return limited, ''
end


-----------------------------------------------------------------------------
-- 获取请求的各项参数
-- 包括请求方法、请求URI、请求body
-- Input
-- @param self 调用者自身self
-- Returns
-- @return http_method 请求的方法，ngx.HTTP_GET、ngx.HTTP_POST
-- @return http_uri 请求的uri
-- @return json_body body体，json格式
-----------------------------------------------------------------------------
function get_req_params(self)
    self.http_method = ngx.HTTP_POST
    self.http_uri = '/idx/ad'
    local body = {}
    local cjson = require('cjson')
    body.post_body = self.core.post_body
    local _, json_body = pcall(cjson.encode, body)
    return self.http_method, self.http_uri, json_body

end

