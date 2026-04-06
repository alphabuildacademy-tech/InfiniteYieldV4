local baseUrl = "https://raw.githubusercontent.com/alphabuildacademy-tech/InfiniteYieldV4/main/src/"

local librarySrc = game:HttpGet(baseUrl .. "source.lua")
_G.Library = loadstring(librarySrc)()

local adminSrc = game:HttpGet(baseUrl .. "AdminPanel.lua")
loadstring(adminSrc)()