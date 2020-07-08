-----------------------------------------------------------------------------
-- 处理ad结构的请求
-- 包括 博文推广(bidfeed)、品牌速递（brand）、微博精选（aim）、非粉（nofans）、粉丝头条（body）
-- 无需调用redis或者接口，在本模块里直接组装好数据格式返回
-- 返回给端上的具体的数据结构由mapi组装
-----------------------------------------------------------------------------
module(..., package.seeall)

function new(self)
    return setmetatable({}, { __index = self })
end

function run(self)
    local cjson = require('cjson')
    ngx.req.read_body()
    local post_params = ngx.req.get_body_data()
    post_params = cjson.decode(post_params)
    local post_body = post_params.post_body
    local ad_counts = post_body.ad_counts
    ad_counts = tonumber(ad_counts)
    if ad_counts == nil then
        ad_counts = 3
    end
    local ads = {}
    while ad_counts >= 1 do
        table.insert(ads, {
            adtype = 1,
            id = "brand_ad_id_" .. tostring(ad_counts),
            product = "brand",
            ad_version = "1",
            recommend = "品牌广告",
            type = "brand",
            monitor_url = "第三方监控链接"
        })
        ad_counts = ad_counts - 1
    end
    ngx.print(cjson.encode(ads))

end
