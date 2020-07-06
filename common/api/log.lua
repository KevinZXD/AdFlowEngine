---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 4:34 PM
---

-----------------------------------------------------------------------------
-- 处理log_by_lua阶段的日志记录
--
-----------------------------------------------------------------------------

local _M = {}
_M.VERSION = '1.0'

local mt = { __index = _M }

function _M.new(self)
    return setmetatable({}, mt)
end

-----------------------------------------------------------------------------
-- 将日志数据保存到磁盘文件
-- 日志需要压缩后保存
-- Input
-- @param logData 日志文件，字符串类型
-- Returns
-- @return
-----------------------------------------------------------------------------
function _M.logToFile(self, logData, uid, mid, mark, request_id, ad_uid)
    local logger = require("lib.log")
    if logData == nil then
        logData = ngx.ctx.log_data
    end
    if logData == nil then
        return
    end
    if type(logData) == 'table' then
        local cjson = require('cjson')
        logData = cjson.encode(logData)
    end
    logger:saveLogToFile(logData)
    -- logger:saveCompressedLogToFile(logData, uid, mid, mark, request_id, ad_uid)
end

-----------------------------------------------------------------------------
-- 将日志数据发送到Redis协议日志收集机
-- Input
-- @param logData 日志文件，字符串类型
-- Returns
-- @return
-----------------------------------------------------------------------------
function _M.logToRedis(self, logData)
    local logger = require("lib.log")
    if logData == nil then
        logData = ngx.ctx.log_data
    end
    if logData == nil then
        return
    end
    if type(logData) == 'table' then
        local cjson = require('cjson')
        logData = cjson.encode(logData)
    end
    logger:sendLogToRedis(logData)
end

-----------------------------------------------------------------------------
-- 将日志数据发送到日志收集Kakfa收集机
-- Input
-- @param logData 日志文件，字符串类型
-- Returns
-- @return
-----------------------------------------------------------------------------
function _M.logToKafka(self, logData)
    local kafka_collector_r = require('config.kafka_collector')
    local main_collector = kafka_collector_r.main
    local backup_collector = kafka_collector_r.backup

    local sock = ngx.socket.tcp()
    local ok, err = sock:connect(main_collector['host'], main_collector['port'])
    if not ok then
        ngx.log(ngx.ERR, "~~~tcp connect main fail,err:" .. err)
        local ok, err = sock:connect(backup_collector['host'], backup_collector['port'])
        if not ok then
            ngx.log(ngx.ERR, "~~~tcp connect backup fail,err:" .. err)
            return false -- 主机器和备用机器都连接失败
        end
    end
    -- 连接成功，发送数据
    sock:settimeout(1000) -- one second timeout
    local bytes, err = sock:send(logData)
    if bytes == nil then
        ngx.log(ngx.ERR, "~~~tcp send data fail,err:" .. err)
        return false -- 发送失败
    end
    sock:close()
    return true
end

return _M