local GetGameTimeSeconds = GetGameTimeSeconds
local table_getsize = table.getsize
local table_insert = table.insert
local math_mod = math.mod
local string_format = string.format

ProgressETA = {}

function ProgressETA:getEtaString()
    return self.etaStr
end

function ProgressETA:getEta()
    return self.eta
end

function ProgressETA:isHasEta()
    return self.hasEtaValue
end

function ProgressETA:update(_progress)
    local gt = GetGameTimeSeconds()
    if _progress<=0 or _progress>=1.0 then
        self:reset(0, gt)
        return
    end
    if self.lastWorkProgress>_progress then
        self:reset(_progress, gt)
    end

    self.hasReset = false
    self.hasEtaValue = true

    local wp = _progress
    local wpDiff = wp-self.lastWorkProgress
    self.lastWorkProgress = wp
    local gtDiff = gt - self.lastGameTime
    self.lastGameTime = gt

    self:calc(wpDiff, gtDiff)

    --print("eta = "..self.etaStr..", progress = "..tostring(_progress)..". wpDiff = "..tostring(wpDiff)..", gtDiff = "..tostring(gtDiff))
end

function ProgressETA:calc(_wp, _gt)
    local wp = 0
    local gt = 0
    local cnt = 0
    local current, next
    for i=self.maxCache-1, 1, -1 do
        current = self.progressCache[i]
        next = self.progressCache[i+1]
        next.wp = current.wp
        next.gt = current.gt
        next.isSet = current.isSet
        if next.isSet then
            wp = wp + next.wp
            gt = gt + next.gt
            cnt = cnt + 1
        end
    end
    current.wp = _wp
    current.gt = _gt
    current.isSet = true

    wp = wp + current.wp
    gt = gt + current.gt
    cnt = cnt + 1

    if cnt>0 and gt > 0 and wp > 0 then
        wp = wp / cnt
        gt = gt / cnt

        local todo = 1.0 - self.lastWorkProgress
        if todo > 0 then
            local seconds = (todo / wp) * gt

            -------------------------
            --seconds = self:averageSeconds(seconds)
            -------------------------

            self.eta = seconds
            self.etaStr = string_format("%.2d:%.2d", seconds / 60, math_mod(seconds, 60))
            --self.etaStr = string_format("%.2d:%.2d:%.2d", seconds / 60 / 60, math_mod(seconds / 60, 60), math_mod(seconds, 60))
            --print("eta = "..self.etaStr..", progress = "..tostring(self.lastWorkProgress)..", seconds = "..tostring(self.eta)..". wp= "..tostring(wp)..", gt = "..tostring(gt)..", todo = "..tostring(todo)..", cnt = "..tostring(cnt))
        end
    end
end

function ProgressETA:averageSeconds(_seconds)
    local secTot = 0
    local secCnt = 0
    for i=self.maxSecCache-1, 1, -1 do
        self.secCache[i+1].seconds = self.secCache[i].seconds
        if self.secCache[i+1].isSet then
            secTot = secTot + self.secCache[i+1].seconds
            secCnt = secCnt + 1
        end
    end
    self.secCache[1].seconds = _seconds
    self.secCache[1].isSet = true
    secTot = secTot + _seconds
    secCnt = secCnt + 1

    return secTot / secCnt
end

function ProgressETA:reset(_progress, _gtSeconds)
    self.lastGameTime = _gtSeconds
    if self.hasReset then
        return
    end
    --print("Resetting ETA")
    self.eta = 0
    self.etaStr = ""
    self.lastWorkProgress = (_progress>=0 and _progress<=1.0) and _progress or 0
    for i=1, self.maxCache do
        self.progressCache[i].isSet = false
    end
    for i=1, self.maxSecCache do
        self.secCache[i].isSet = false
    end
    self.hasReset = true
    self.hasEtaValue = false
end

function ProgressETA:new(_progress)
    local o = {}
    setmetatable(o,self)
    self.__index = self

    o.eta = 0
    o.etaStr = ""
    o.lastGameTime = GetGameTimeSeconds()
    o.lastWorkProgress = _progress
    o.progressCache = {}
    o.hasEtaValue = false
    o.maxCache = 60
    for i=1, o.maxCache do
        table_insert(o.progressCache, {
            wp = 0,
            gt = 0,
            isSet = false
        })
    end
    o.maxSecCache = 10
    o.secCache = {}
    for i=1, o.maxSecCache do
        table_insert(o.secCache, {
            seconds = 0,
            isSet = false
        })
    end
   return o
end