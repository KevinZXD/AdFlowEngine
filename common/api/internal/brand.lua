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
    local redis = require('service.redis')
    local resp, _ = redis.getAllByKeyNew('ad_online_brand', 'remote')

    local online_brand = {}
    for k, _ in pairs(resp) do
        if k % 2 ~= 0 then
            online_brand[resp[k]] = cjson.decode(resp[k + 1])
        end

    end
    for brand, brand_tb in pairs(online_brand) do

        table.insert(ads, {
            adtype = 1,
            id = brand,
            product = brand_tb.product,
            ad_version = brand_tb.version,
            recommend = brand_tb.name,
            type = "brand",
            monitor_url = brand_tb.monitor_url
        })
        ad_counts = ad_counts - 1
        if ad_counts <= 0 then
            break
        end
    end
    ngx.print(cjson.encode(ads))

end
