-- Hammerspoon init.lua: simple Magnet-like window management
local hotkey = require "hs.hotkey"
local window = require "hs.window"
local screen = require "hs.screen"
local geometry = require "hs.geometry"

local mash = {"ctrl","alt","cmd"}

local function moveToUnit(unit)
  local win = window.focusedWindow()
  if not win then return end
  local f = win:screen():frame()
  local newframe = { x = f.x + unit.x * f.w, y = f.y + unit.y * f.h, w = unit.w * f.w, h = unit.h * f.h }
  win:setFrame(newframe)
end

-- Left/right halves
hotkey.bind(mash, "Left", function() moveToUnit({x=0,y=0,w=0.5,h=1}) end)
hotkey.bind(mash, "Right", function() moveToUnit({x=0.5,y=0,w=0.5,h=1}) end)

-- Maximize
hotkey.bind(mash, "Up", function() moveToUnit({x=0,y=0,w=1,h=1}) end)

-- Center (60% width)
hotkey.bind(mash, "C", function() moveToUnit({x=0.2,y=0.1,w=0.6,h=0.8}) end)

-- Thirds (cycles)
hotkey.bind(mash, "1", function() moveToUnit({x=0,y=0,w=1/3,h=1}) end)
hotkey.bind(mash, "2", function() moveToUnit({x=1/3,y=0,w=1/3,h=1}) end)
hotkey.bind(mash, "3", function() moveToUnit({x=2/3,y=0,w=1/3,h=1}) end)

-- Move window to next screen
hotkey.bind(mash, "N", function()
  local win = window.focusedWindow()
  if not win then return end
  local s = win:screen()
  local nexts = s:next()
  if nexts then win:moveToScreen(nexts) end
end)

-- Open a new Terminal window
hotkey.bind(mash, "T", function()
  hs.execute([[osascript -e 'tell application "Terminal" to do script ""']])
end)

hs.alert.show("Hammerspoon: window hotkeys loaded")
