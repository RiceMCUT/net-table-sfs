local EncodeCache = {}

---@type SFS
local sfs = include("includes/modules/sfs.lua")

function net.ReadTable()
    local size = net.ReadUInt(32)

    if size == 0 then
        return {}
    end

    return sfs.decode(util.Decompress(net.ReadData(size)))
end

function net.WriteTable(tbl)
    if next(tbl) == nil then
        net.WriteUInt(0, 32)

        return
    end

    local raw_data = sfs.encode(tbl)

    if not raw_data then
        net.WriteUInt(0, 32)

        return
    end

    local hash = util.SHA256(raw_data)
    local compressed_data = EncodeCache[hash]

    if not compressed_data then
        compressed_data = util.Compress(raw_data)

        EncodeCache[hash] = compressed_data
    end

    local size = #compressed_data

    net.WriteUInt(size, 32)
    net.WriteData(compressed_data, size)
end
