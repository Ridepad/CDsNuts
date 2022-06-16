local DB = {
    spellsDB = {},
    spellCacheDefault = {},
}

_G.CDsNutsDB = DB

local spellsDB = DB.spellsDB
local spellCache = DB.spellCacheDefault

DB.classColors = {
    ["DRUID"] = "ffff7c0a",
    ["SHAMAN"] = "ff0070dd",
    ["ROGUE"] = "fffff468",
    ["PRIEST"] = "ffffffff",
    ["WARLOCK"]=  "ff9382c9",
    ["DEATHKNIGHT"] = "ffc41e3a",
    ["WARRIOR"] = "ffc69b6d",
    ["PALADIN"] = "fff48cba",
    ["MAGE"] = "ff68ccef",
    ["HUNTER"] = "ffaad372",
}

local __spells = {
    -- [22812] =  { --bark
    --     color = {1,1,0,1},
    --     cd = 60,
    --     rows = 2,
    --     row = 0,
    -- },
    -- [53251] =  { --wg
    --     color = {0,1,0,1},
    --     cd = 65,
    --     rows = 3,
    --     row = -2,
    -- },
    -- [48441] =  { --rejuv
    --     color = {0.5, 0.15, 0.4, 1},
    --     cd = 480,
    --     rows = 2,
    --     row = 6,
    --     col = 2,
    -- },

    [64205] =  { --dsac
        color = {1, 0.85, 0.15, 1},
        cd = 120,
        rows = 2,
        row = 28,
        class = "PALADIN",
    },
    [64901] =  { --mana hymn
        color = {0.9, 0.9, 0.9, 1},
        cd = 360,
        rows = 2,
        row = 28,
        col = 1,
        class = "PRIEST",
    },
    [16190] =  { --tide
        color = {0.2, 0.2, 1, 1},
        cd = 300,
        rows = 2,
        row = 28,
        col = 2,
        class = "SHAMAN",
    },
    [31821] =  { --am
        color = {1, 0.85, 0.15, 1},
        cd = 120,
        rows = 2,
        row = 26,
        class = "PALADIN",
    },
    [64843] =  { --heal hymn
        color = {1, 0.85, 0.15, 1},
        cd = 480,
        rows = 2,
        row = 26,
        col = 1,
        class = "PRIEST",
    },
    [10060] =  { --pi
        color = {1, 0.85, 0.35, 1},
        cd = 96,
        rows = 1,
        row = 24,
        hasTarget = 1,
        class = "PRIEST",
    },
    [49016] =  { --hyst
        color = {1, 0, 0, 1},
        cd = 180,
        rows = 1,
        row = 23,
        hasTarget = 1,
        class = "DEATHKNIGHT",
    },
    [1044] =  { --hof
        color = {1, 0.25, 0, 1},
        cd = 25,
        rows = 2,
        row = 22,
        hasTarget = 1,
        class = "PALADIN",
    },
    [10278] =  { --hop
        color = {1, 0, 0, 1},
        cd = 300,
        rows = 3,
        row = 20,
        hasTarget = 1,
        class = "PALADIN",
    },
    [6940] =  { --hos
        color = {1, 0, 0, 1},
        cd = 120,
        rows = 2,
        row = 17,
        hasTarget = 1,
        class = "PALADIN",
    },
    [1038] =  { --hosalv
        color = {0.5, 0.85, 0.25, 1},
        cd = 120,
        rows = 4,
        row = 14,
        hasTarget = 1,
        class = "PALADIN",
    },
    [34477] =  { --md
        color = {0.1, 0.9, 0.9, 1},
        cd = 30,
        rows = 3,
        row = 10,
        hasTarget = 1,
        class = "HUNTER",
    },
    [57934] =  { --tot
        color = {1, 1, 0.15, 1},
        cd = 30,
        rows = 3,
        row = 7,
        hasTarget = 1,
        class = "ROGUE",
    },
    [29166] =  { --inner
        color = {0.1, 0.35, 0.7, 1},
        cd = 180,
        rows = 3,
        row = 4,
        hasTarget = 1,
        class = "DRUID",
    },
    [48477] =  { --rebirth
        color = {1, 0.1, 0.1, 1},
        cd = 600,
        rows = 3,
        row = 1,
        hasTarget = 1,
        class = "DRUID",
    },
    [47883] =  { --ss
        color = {0.75, 0.15, 0.55, 1},
        cd = 900,
        rows = 3,
        row = -2,
        hasTarget = 1,
        class = "WARLOCK",
    },
}

for spellID, t in pairs(__spells) do
    local name, _, icon = GetSpellInfo(spellID)
    t.icon = icon
    t.link = GetSpellLink(spellID)
    spellsDB[name] = t
    spellCache[name] = {}
end
