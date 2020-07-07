---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/7/6 4:54 PM
---



local function get_respid()
    local time=os.time()
    math.randomseed(time)
    local rand=math.random(100000,999999)
    return tostring(time)..tostring(rand)
end


local IDX = {}
local utils = require('lib.utils')
local cjson = require('cjson')
function IDX:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
local PRODUCT_MODULE_CLASSES = {}
local PRODUCT_MODNAMES = {sfst='sfst_ad',wax='wax_ad'}
for product_name,module_name in pairs(PRODUCT_MODNAMES) do
    PRODUCT_MODULE_CLASSES[product_name] = require(string.format("ad_idx.modules.%s", module_name))
end


-- 初始化
-- 所有可能用到的变量，在此声明
-- param req_body为uve请求体body字符串
-- param uve 解析后的uve请求体结构
function IDX:init(req_body, uve)
    self.uve=uve
    self.req_body = req_body
    self.post_data = {} -- 请求广告引擎需要的POST数据
    -- 本次流量要出哪些产品线的广告 {"A", "B",...}
    self.strategy_products = uve.strategy_products -- 业务策略中指出的且IDX已支持的产品线, 数组
    self.products =uve.strategy_products -- 经过流量控制等过滤后，最终决定访问哪些产品线, 数组
    self.module_dict = {} -- 对应各个引擎模块 {"product":module, ...}
    self.capture_requests = {} -- capture的请求串，数组
    self.responses = {} -- 并行请求各业务线的返回结果，数组
    self.target_ads= {}
    self.winners = {} -- 竞价胜出的广告, 数组
    self.is_debug = req_body.is_debug
end

-- 检查Sfst的请求是否有效
-- @return 有效返回ture，否则返回false
function IDX:parse_sfst_request()
    return true
end

-- 对上游请求进行初始化
function IDX:init_request()

end

-- 获取单次请求的竞价广告位首位
-- 备注：仅在主信息流和分组流区分竞价位首位
-- 例如某次下发的广告位为[1,3,10,15], 竞价广告位首位为3
function IDX:get_req_first_bid_pos()

end

-- 获取单次请求的竞价广告位末位
-- 备注: 仅在主信息流区分竞价位末位
-- 例如某次下发的广告位为[1,3,10,15], 竞价广告位末位为15
function IDX:get_req_last_bid_pos()

end

-- 特殊广告位可出候选类型过滤
-- @param origin_bidding_weight 初始的权重列表
-- @param cand_types 允许填充的候选类别列表
-- @param is_wl 过滤模式, true代表白名单过滤, false代表黑名单过滤
-- @return 过滤后的结果
function IDX:filter_imp_cand_type(origin_bidding_weight, cand_types, is_wl)

end

-- 将排序后的竞价权重列表转为字典
-- @param bwt_list 竞价权重列表
-- @return table 竞价权重字典
function IDX:convert_bw_list2dict(bwt_list)

end

-- 指定特殊广告位竞价权重设置
-- 包含: 主信息流首位和竞价位末位，分组流首位及热门微博流首位
-- @return 生成成功返回true，否则返回false
function IDX:assign_imp_bidding_weight()

    -- 其他场景无特殊竞价权重要求
end

-- 检查uve策略中指定的竞价权重是否合法
-- @param bidding_weight UVE策略中指定的竞价权重配置
-- @return 配置有效返回true, 否则返回false
function IDX:check_strategy_bidding_wt()
    return true
end

-- 检查uve的请求数据是否合法
-- @return 有效返回true，否则返回false
function IDX:parse_request()
    return true
end

-- 广告黑名单过滤
function IDX:apply_prefilter_black_user()
    local idx_blacklist = require('ad_idx.idx_black_list')
    if not idx_blacklist.is_black_user(self.uve.uid) then
        return
    end
end

-- 用户过滤
function IDX:apply_prefilter()
    self:apply_prefilter_black_user()
end

-- 应用过滤规则
function IDX:apply_filter_rules()

end

-- 应用灰度策略
function IDX:apply_gray()
end

function IDX:apply_strategy()

end



-- 流量控制：流量百分比、降级等
function IDX:flow_control()

end

function IDX:prerequest_filter() end

function IDX:prerequest_handle()
    local profile = require('ad_idx.profile')
    -- 获取用户唯一标识
    self.user_identifier_info = profile.get_user_identifier_info(self.uid)

end

--根据流量类型采取过滤产品线等策略
function IDX:apply_flow_strategy()

end

function IDX:get_imps_with_product(product)

end

-- 根据产品线下发实验策略
-- @param product 业务规范中定义的产品线英文名称
-- @return 该产品线应下发的实验信息
function IDX:get_experiment_with_product(product)
    -- 为各产品线下发实验
end

-- 初始化试验策略
-- 备注: 没有运行实验时，返回结果中不存在description字段
-- @return true 成功，false 失败
function IDX:init_experiment()
    return true
end

-- 依据实验信息过滤请求
function IDX:experiment_filter()

end

-- 特殊广告位请求前过滤
-- 目标: 当特殊广告位不包含某产品线下任何候选类型, 则不对该产品线下发该广告位
function IDX:filter_product_imps(product, imps)

end


-- 初始化广告引擎模块
-- @return true 成功，false 失败
function IDX:init_module()
    local module_dict = {}
    for _,product in ipairs(self.strategy_products) do
        local module_class = PRODUCT_MODULE_CLASSES[product]
        local m = module_class:new(self.uve)
        module_dict[product] = m
    end
    self.module_dict = module_dict
    return true
end

-- 调用各广告引擎模块，生成请求串
function IDX:generate_requests()
    -- 若某product生成request失败，则不请求该product的引擎，它也不参与竞价。
    local products = {}
    for _,product in ipairs(self.products) do
        local m = self.module_dict[product]
        local rc, request = m:generate_request(self.uve)
        if rc == true then

            table.insert(products, product)
            table.insert(self.capture_requests, request)
        end
    end
    self.products = products
end

-- 并行发起请求
function IDX:capture_multi()
    if next(self.capture_requests) == nil then
        ngx.log(ngx.ERR, "at least one subrequest should be specified")
        return false
    end
    self.responses = { ngx.location.capture_multi(self.capture_requests) }

end

-- 解析各广告引擎的返回结果
function IDX:parse_responses()
    for i,product in ipairs(self.products) do
        local m = self.module_dict[product]
        m:parse_response(self.responses[i])
        table.insert(self.target_ads,m.result_dict)
        if self.is_debug then
            ngx.say("########## Response " .. product)
            ngx.say(self.responses[i].body)
        end

        if self.responses[i].status ~= ngx.HTTP_OK then
            ngx.log(ngx.ERR, string.format("capture %s ",
                    product))
        end
    end
end

-- 候选结果过滤
function IDX:response_filter()

end

-- 对候选进行广告主过滤
function IDX:candidates_filter_cust_id(candidates)
    if candidates == nil or next(candidates) == nil then
        return
    end

end


-- prebid阶段获取impid对应的候选
function IDX:prebid_get_cands(impid)
    local cands = {} -- [{},...]

    return cands
end

-- bid阶段获取impid对应的候选
function IDX:bid_get_cands(impid)

end

-- 获取托价队列
--  托价队列：本次流量的所有候选中，竞价值小于winner竞价值的候选集合
--  若无，则什么也不返回
function IDX:get_leaves_with_winner(winner)
end

-- 底价过滤&动态起拍价过滤
function IDX:apply_floor_price(cand, cash_coef, product_coef, channel_coef)

end


-- 竞价前处理逻辑 品速融入超粉灰度版本
--1. 获取所有广告位所有候选
--2. 设置所有候选竞价权重
--3. 计算所有候选竞价值并进行底价过滤
--4. 广告主候选黑名单过滤
function IDX:prebid_handler()
end



-- 竞价
function IDX:bid()
    -- 计算所有广告位所有候选，并进行底价过滤
    self:prebid_handler()
    local BidModel = require("ad_idx.idx_bid_model")
    local winners = {}
    local cands = self.target_ads

    if next(cands) then
        local params = {
            service = self.uve.service,
            strategy = self.uve.strategy,
            cands = cands,
            model_version = "v1"
        }
        local model = BidModel:new(params)
        winners = model:bid()
    end


    -- 尾部投放,只有存在于有未填充广告的广告位时
    self:tail_push(winners)

    self.winners = winners
    --ngx.log(ngx.DEBUG, "wins ", IUtils.json_encode(self.winners))
end

-- 删除有广告胜出的广告位
function IDX:delete_impid(impid)
end

-- 尾部投放，在存在有未填充广告的广告位时，将SmartD的未曝光候选填入
function IDX:tail_push(winners)

end

-- 在相应的产品模块中，添加在尾部投放中填充的候选
function IDX:push_tail_wins(cand)
end

-- 竞价后置逻辑
function IDX:postbid()

end

function IDX:generate_response_part_ext()
    local ext = {}
    return ext
end

-- 生成response，并回复客户端
function IDX:response_uve()
    local resp_data = {}
    resp_data.id = self.uve.uid or ""
    resp_data["data"] = {}
    for _,winner in ipairs(self.winners) do
        local resp_data_ = {}
        resp_data_["service"] = winner["service"]
        resp_data_["position"] = winner["position"]
        resp_data_["id"] = winner["id"]
        resp_data_["bid_price"] = winner["bid_price"]
        resp_data_["ad_type"] = winner["ad_type"]
        resp_data_["product"] = winner["product"]
        resp_data_["recommend"] = winner["recommend"]
        table.insert(resp_data["data"],resp_data_)
    end
    ngx.say(cjson.encode(resp_data))
end

-- 获取尾部投放的引擎未胜出的广告候选
function IDX:get_leaves_candidates()

end

-- 返回记录频次日志的请求
-- 频次日志需要记录到RIN

-- @return table 所有的频次请求
function IDX:record_freqlog()
end


-- 记录各产品线曝光信息
function IDX:record_explog()

end

-- 记录竞价跟踪日志(本地)
-- 新增experiment字段
function IDX:record_trace_log()

end

-- 收官 [>\/<]
--  1. 记录一切需要记录到本地的、网络的数据
--  2. 请求那些在结束时，需要访问网络的request，
--     这里只发起请求，不会处理响应，也不关心成功失败
--  3. 这里均用 self.strategy_products 来遍历module
--     有些业务不获取广告数据，但需IDX记录某些信息，如
--     AddFans的移动端不感兴趣，不候补广告，但需记录不感兴趣
function IDX:finalize_handler()
    -- 先返回数据给UVE，后做其他处理
    -- NOTE: 返回给UVE的耗时没有包含写频次，记录曝光日志的时间
    self:response_uve()

    -- 记录各产品线曝光日志
    self:record_explog()
end

-- 请求处理主流程
-- param req_body为uve请求体body字符串
-- param uve 解析后的uve请求体结构
function IDX:run(req_body, uve)
    -- NOTE: 不可改变以下函数的调用顺序
    -- 初始化
    self:init(req_body, uve)

    -- 解析UVE请求
    if self:parse_request() == false then
        self:response_uve()
        return
    end

    -- 前置过滤
    self:apply_prefilter()

    -- IDX灰度策略
    self:apply_gray()

    -- 应用业务策略
    self:apply_strategy()

    -- 应用黑名单过滤
    self:apply_filter_rules()

    -- 应用流量控制
    self:flow_control()

    -- 请求前过滤
    self:prerequest_filter()

    -- 应用流量策略
    self:apply_flow_strategy()

    -- 请求画像及依赖资源
    self:prerequest_handle()

    --初始化试验策略
    self:init_experiment()

    -- 依据实验过滤流量
    self:experiment_filter()

    -- 初始化广告引擎模块
    self:init_module()

    -- 生成请求串
    self:generate_requests()

    -- 并行请求广告引擎
    self:capture_multi()

    -- 解析响应
    self:parse_responses()

    -- 过滤
    self:response_filter()

    -- 竞价
    self:bid()

    -- 竞价后置逻辑
    self:postbid()

    -- 收官[>\/<]
    self:finalize_handler()

end

return IDX

