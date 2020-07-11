---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/7/6 7:23 PM
---

--  竞价模型V3
--  特性：依据候选的竞价权重竞价(bidding_weight)，同时继承V2版本商广优先策略
--
--
--  竞价逻辑:
--  1. 比较所有候选的[竞价权重]，获取最高[竞价权重]的候选
--  2. 若综合[竞价权重]最高的候选只有一个，则该候选胜出
--  3. 若综合[竞价权重]最高的候选有多个，根据渠道将候选划分为运营广告和普通广告两类
--  4. 若普通广告类型仅包含一个候选, 则该候选胜出
--  5. 若普通广告类型包含多个候选, 则进一步比较普通广告候选的竞价值, 竞价值最高者胜出
--  6. 若普通广告类型没有候选, 则进入运营广告竞价环节
--  7. 若运营广告类型仅包含一个候选, 则该候选胜出
--  8. 若运营广告类型包含多个候选, 则进一步比较运营广告候选的竞价值, 竞价值最高者胜出
--
--  Note: 本模块及其子模块[能且仅能]修改cands[i].inter内的数据，对其他数据结构不得做修改。


local _M = { _VERSION = "0.0.1"}
local cjson = require('cjson')
_M.name = "idx_bid_model_v3"

-- 依据竞价权重竞价
-- @param cands 参与竞价候选列表
-- @return table 最高竞价权重的候选列表
function _bid_by_weight(cands)
    if not cands or not next(cands) then
        return {}
    end
    if #cands == 1 then
        return cands
    end

    -- 获取竞价权重最高的候选列表
    local max_wt = 0
    local max_wt_cands = {}
    for i, cand in ipairs(cands) do
        if cand.value.bid_wt > max_wt then
            max_wt = cand.value.bid_wt
            max_wt_cands = {cand}
        elseif cand.value.bid_wt == max_wt then
            table.insert(max_wt_cands, cand)
        end
    end

    return max_wt_cands
end

-- 竞价值竞价
-- @param cands 参与竞价值竞价候选列表
-- @param table 最高竞价值候选列表
function _bid_by_score(cands)
    if not cands or not next(cands) then
        return {}
    end
    if #cands == 1 then
        return cands
    end

    -- 获取竞价值最高的候选列表
    local max_score = 0
    local max_score_cands = {}
    for i, cand in ipairs(cands) do
        if cand.value.bid_value > max_score then
            max_score = cand.value.bid_value
            max_score_cands = {cand}
        elseif cand.value.bid_value == max_score then
            table.insert(max_score_cands, cand)
        end
    end

    return max_score_cands
end

-- 计算最优广告
-- @parma table cands
-- @return table 返回候选集中竞价最优的广告，无候选则返回nil
function _M.bid(cands,ad_counts)
    local utils = require('lib.utils')
    local tar_ads = utils.deepcopy(cands)
    ngx.log(ngx.ERR,cjson.encode(tar_ads))
    local target_ads = {}
    ad_counts = tonumber(ad_counts)
    while ad_counts and ad_counts>=1
         do
            local ad = bid_only_one(tar_ads)
            local copy = utils.deepcopy(ad)
            table.insert(target_ads,copy)
            local index= find_index(tar_ads,ad)
            table.remove(tar_ads,index)
            ad_counts=ad_counts-1
        end
    return target_ads

end
function find_index(cands,ad)
    for index,value in pairs(cands) do
        if  value.id == ad.id then
            return index
        end
    end
end
function bid_only_one(cands)
    if next(cands) == nil then
        return nil
    end
    -- 竞价权重竞价
    local max_wt_cands = _bid_by_weight(cands)
    if not next(max_wt_cands) then
        return nil
    end
    -- 最高优先级候选仅一个, 直接胜出
    if #max_wt_cands == 1 then
        return max_wt_cands[1]
    end
    -- 最高优先级候选有多个, 根据渠道将候选划分为运营广告和普通广告两类
    local inner_cands = {}
    local normal_cands = {}
    for _, cand in ipairs(max_wt_cands) do
        if cand.channel == "inner" then
            table.insert(inner_cands, cand)
        else
            table.insert(normal_cands, cand)
        end
    end

    -- 普通广告竞价
    if next(normal_cands) then
        -- 普通广告候选仅一个, 直接胜出
        if #normal_cands == 1 then
            return normal_cands[1]
        end
        -- 普通广告候选多个, 使用竞价值竞价
        local max_score_cands = _bid_by_score(normal_cands)
        if not max_score_cands or not next(max_score_cands) then
            return nil
        end
        -- 默认返回第一个竞价值最高候选
        return max_score_cands[1]
    end
    -- 运营广告竞价
    if next(inner_cands) then
        -- 运营广告候选仅一个, 直接胜出
        if #inner_cands == 1 then
            return inner_cands[1]
        end
        -- 运营广告候选多个, 使用竞价值竞价
        local max_score_cands = _bid_by_score(inner_cands)
        if not max_score_cands or not next(max_score_cands) then
            return nil
        end
        -- 默认返回第一个竞价值最高候选
        return max_score_cands[1]
    end
end

return _M
