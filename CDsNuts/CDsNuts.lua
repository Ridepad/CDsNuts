-- press shift/alt to see available/dead
-- range for inner/br, closest target?

local ADDON_NAME = "CDsNuts"

local ADDON = CreateFrame("Frame", ADDON_NAME, UIParent)
_G[ADDON_NAME] = ADDON

local DB = _G[ADDON_NAME .. "DB"]
local SPELLS_DB = DB.spellsDB
local SPELLS_CACHE = DB.spellCacheDefault
local CLASS_COLORS = DB.classColors

local FRAME_BUFFER = {}

local SETTINGS = {
    POS_X = 123,
    POS_Y = -155,
    SIZE_H = 13,
    SPACING = 2,
    BORDER_MARGIN = 0,
    REPORT_TO = "RAID",
}


local SIZE_W = 200
local SIZE_H = 13
local SPACING = 2
local BG_ALPHA = 0.4
local ZOOM = 0.1
local TW = 0.45

local FULL_W = SIZE_W + 5
local FULL_H = SIZE_H + SPACING
local REPORT_TO = "RAID"
local ZZOOM = 1 - ZOOM

local ADDON_MEDIA = "Interface\\Addons\\" .. ADDON_NAME .. "\\Media\\%s"
local FONT = ADDON_MEDIA:format("Emblem.ttf")
local BORDER_TEXTURE = ADDON_MEDIA:format("BigBorder.blp")
local BAR_BACKGROUND = ADDON_MEDIA:format("Serenity.tga")

local BAR_BACKDROP = {
    edgeFile = BORDER_TEXTURE,
    tile = true,
    edgeSize = 8,
}

local ADDON_PROFILE = ADDON_NAME .. "Profile"
local ADDON_NAME_COLOR = format("|cFF556699[%s]|r: ", ADDON_NAME)

SLASH_RIDEPAD_COOLDOWNS1 = "/rcdp"
SlashCmdList["RIDEPAD_COOLDOWNS"] = function()
    UpdateAddOnCPUUsage()
    print(format("%s Total CPU: %.1f ms", ADDON_NAME_COLOR, GetAddOnCPUUsage(ADDON_NAME)))
end

local AddToCache = function(self, spellName)
    local cache = SPELLS_CACHE[spellName]
    for _, f in ipairs(cache) do
        if f.frameID == self.frameID then return end
    end
    cache[#cache+1] = self
end

local reposition = function(spellName)
    local spellInfo = SPELLS_DB[spellName]
    local cache = SPELLS_CACHE[spellName]
    local q = cache[next(cache)]
    local colshift = spellInfo.col or 0
    local small = q and q.tName and 1 or 2
    local y = spellInfo.row * FULL_H
    for shift, f in ipairs(cache) do
        shift = shift - 1
        local row = shift % spellInfo.rows
        local col = floor(shift/spellInfo.rows)/small + colshift
        f:SetPoint("LEFT", col*FULL_W, y - row*FULL_H)
    end
end


local SortFramesGroup = function(spellName, nullify)
    local cache = SPELLS_CACHE[spellName]
    sort(cache, function(a, b) return a.p < b.p end)
    if nullify then
        cache[#cache] = nil
    end

    reposition(spellName)
end

local FrameHide = function(self)
    self.p = 1000

    SortFramesGroup(self.spellName, true)

    self:UnregisterAllEvents()
    self:Hide()
end

local OnUpdate = function(self, e)
    if self.standby then return end
    if not self.p then return end
    local p = self.p - e
    self.p = p > 0 and p or self:FrameHide()
    self:SetValue(p)
    if p > 60 then
        self.durText:SetFormattedText("%d:%02d", p/60, p%60)
    else
        self.durText:SetFormattedText("%d", p)
    end
end

local SetNames = function(self, sName, tName, tGUID)
    self.sName = sName
    self.tName = tName
    self.tGUID = tGUID

    self.srcText:SetText(sName)
    if tName then
        if tGUID and tGUID:sub(1,3) == "0x0" then
            local _, class = GetPlayerInfoByGUID(tGUID)
            local color = CLASS_COLORS[class]
            if color then
                tName = format("|c%s%s|r", color, tName)
            end
        end
        self:SetWidth(SIZE_W)
        tName = "> "..tName
    else
        self:SetWidth(SIZE_W/2)
    end

    self.dstText:SetText(tName)

    self:SetScript("OnUpdate", OnUpdate)
    self:Show()
end

local FrameInit = function(self, spellName, standby, durLeft)
    self.standby = standby
    if standby then self.durText:SetText() end

    self:AddToCache(spellName)

    local spellInfo = SPELLS_DB[spellName]
    local dur = durLeft or spellInfo.cd
    self.p = dur
    self.finish = GetTime() + dur
    self:SetValue(dur)
    if self.spellName ~= spellName then
        self.spellName = spellName
        self:SetMinMaxValues(0, spellInfo.cd)
        self:SetStatusBarColor(unpack(spellInfo.color))
        self.icon.tex:SetTexture(spellInfo.icon)
    end

    SortFramesGroup(self.spellName)

    return self
end


-- FRAME CREATOR
local SetBackground = function(self)
    local bg = self:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(BAR_BACKGROUND)
    bg:SetAllPoints()
    bg:SetVertexColor(0, 0, 0, BG_ALPHA)
    return bg
end

local SetBorder = function(parent)
    local border = CreateFrame("Frame", nil, parent)
	border:SetBackdrop(BAR_BACKDROP)
	border:SetBackdropBorderColor(0, 0, 0, 1)
    border:SetPoint("TOPLEFT", -SPACING, SPACING)
    border:SetPoint("BOTTOMRIGHT", SPACING, -SPACING)
    return border
end

local SetIcon = function(parent)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetPoint("TOPLEFT")
    icon:SetSize(SIZE_H, SIZE_H)
    icon.tex = icon:CreateTexture(nil, "OVERLAY")
    icon.tex:SetAllPoints()
    icon.tex:SetTexCoord(ZOOM, ZOOM, ZOOM, ZZOOM, ZZOOM, ZOOM, ZZOOM, ZZOOM)
    return icon
end

local NewFont = function(parent, justify)
    local font = parent:CreateFontString(nil, "OVERLAY")
    font:SetFont(FONT, SIZE_H, "OUTLINE")
    font:SetHeight(SIZE_H+1)
	font:SetJustifyH(justify)
	font:SetShadowColor(0, 0, 0, 1)
	font:SetShadowOffset(1, -1)
    return font
end

local OnMouseDown = function(self, button)
    -- print('OnMouseDown', arg1)
    local spellData = SPELLS_DB[self.spellName]
    local link = spellData and spellData.link or self.spellName
    local dur = self.durText:GetText() or "Standby"
    local msg = format("%s %s || CD: %s", link, self.sName, dur)
    if self.tName then
        msg = format("%s || Target: %s", msg, self.tName)
    end
    SendChatMessage(msg, REPORT_TO)
end

local CreateBufferFrame = function(frameID)
    local self = CreateFrame("StatusBar", ADDON_NAME .. frameID, UIParent)

    -- print('create_buffer_frame', frameID)

    self.frameID = frameID
    self:SetSize(SIZE_W, SIZE_H)
	self:SetStatusBarTexture(BAR_BACKGROUND)

    self.bg = SetBackground(self)
    self.border = SetBorder(self)
    self.icon = SetIcon(self)

    local FW = SIZE_W - SIZE_H * 3.5
    local LT = FW * TW
    self.srcText = NewFont(self, "LEFT")
	self.srcText:SetPoint("TOPLEFT", SIZE_H, 1)
    self.srcText:SetWidth(LT)

    self.dstText = NewFont(self, "LEFT")
	self.dstText:SetPoint("TOPLEFT", SIZE_H+LT, 1)
    self.dstText:SetWidth(FW * (1-TW))

    self.durText = NewFont(self, "RIGHT")
	self.durText:SetPoint("BOTTOMRIGHT")
    self.durText:SetWidth(SIZE_H*3)

    self:SetScript("OnMouseDown", OnMouseDown)

    self.SetNames = SetNames
    self.FrameInit = FrameInit
    self.FrameHide = FrameHide
    self.AddToCache = AddToCache

    return self
end

local NewFrame = function()
    local i = #FRAME_BUFFER+1
    local f = CreateBufferFrame(i)
    FRAME_BUFFER[i] = f
    return f
end

local GetFrame = function(sName, spellName)
    local cache = SPELLS_CACHE[spellName]
    if cache then
        for _, f in ipairs(cache) do
            if f.spellName == spellName and f.sName == sName then
                -- print('from cache', f.frameID)
                return f
            end
        end
    end
    for _, f in pairs(FRAME_BUFFER) do
        if not f.p then
            -- print('from buffer', f.frameID)
            return f
        end
    end
    return NewFrame()
end

local unpack_cache = function(spellName, data)
    if not SPELLS_CACHE[spellName] then return end
    for _, f in pairs(data) do
        local durLeft = f.finish - GetTime()
        if f.sName and durLeft > 0 and durLeft < 15*60 then
            NewFrame():FrameInit(spellName, nil, durLeft):SetNames(f.sName, f.tName, f.tGUID)
        end
    end
end

local getstanby = function()
    
end

local LOADED = false
local OnLoad = function()
    local guid = UnitGUID('player')
    if not guid or not GetPlayerInfoByGUID(guid) then return end

    local t = _G.CDsNutsCache or {}
    for spellName, data in pairs(t) do
        unpack_cache(spellName, data)
    end
    _G.CDsNutsCache = SPELLS_CACHE
    LOADED = true
    getstanby()
end

function ADDON:OnEvent(event, arg1, arg2)
    -- print(event, arg1, arg2)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not SPELLS_DB[arg10] then return end
        if arg9 == 57934 or arg9 == 34477 then
            local f = GetFrame(arg4, arg10)
            if arg2 == "SPELL_CAST_SUCCESS" then
                f:FrameInit(arg10, true):SetNames(arg4, arg7, arg6)
            elseif arg2 == "SPELL_AURA_REMOVED" then
                f:FrameInit(arg10):SetNames(arg4, f.tName, f.tGUID)
            end
        elseif arg2 == "SPELL_CAST_SUCCESS"
        or arg9 == 47883 and arg2 == "SPELL_AURA_APPLIED"
        or arg9 == 48477 and arg2 == "SPELL_RESURRECT" then
            GetFrame(arg4, arg10):FrameInit(arg10):SetNames(arg4, arg7, arg6)
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if not SPELLS_DB[arg2] then return end
        local sName = UnitName(arg1)
        local tName = SPELLS_DB[arg2].hasTarget and "???"
        GetFrame(sName, arg2):FrameInit(arg2):SetNames(sName, tName)
    elseif event == "MODIFIER_STATE_CHANGED" then
        -- LSHIFT RSHIFT LCTRL RCTRL LALT RALT
        if arg1 == "LSHIFT" then
            local changed = arg2 == 1
            for _, frame in ipairs(FRAME_BUFFER) do
                frame:EnableMouse(changed)
            end
        elseif arg1 == "LCTRL" then
            -- if used = save as standby
            -- if class == spell class add to cache
        end
    elseif event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then return end
        OnLoad()
    elseif event == "UNIT_NAME_UPDATE" then
        if arg1 ~= 'player' then return end
        OnLoad()
    elseif event == "PARTY_MEMBERS_CHANGED" then
        if not LOADED then return end
        getstanby()
    end
end

ADDON:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ADDON:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ADDON:RegisterEvent("MODIFIER_STATE_CHANGED")
ADDON:RegisterEvent("ADDON_LOADED")
ADDON:RegisterEvent("UNIT_NAME_UPDATE")
ADDON:RegisterEvent("PARTY_MEMBERS_CHANGED")
ADDON:SetScript("OnEvent", ADDON.OnEvent)
