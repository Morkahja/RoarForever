"""Run with Python + lupa (Lua 5.1). No files are written to the game folder."""
from pathlib import Path
import re
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def boot(locale='enUS', saved=None):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().testLocale = locale
    lua.execute('''
        frames={}; sounds={}; sent={}; stopped={}; timers={}; SlashCmdList={}; UISpecialFrames={}
        now=100; grouped=false; units={player={name='Tester',realm='Home',guid='Player-self'},
            target={name='Other',realm='Away',guid='Player-other'}}
        function GetLocale() return testLocale end
        local noop=function() end
        local methods={}
        for _,k in ipairs({'SetSize','SetPoint','SetFrameStrata','SetClampedToScreen',
            'SetMovable','EnableMouse','RegisterForDrag','StartMoving','StopMovingOrSizing',
            'SetWidth','SetJustifyH','SetScrollChild','SetTexture','SetOwner'}) do methods[k]=noop end
        function methods:SetText(t) self.text=t end
        function methods:RegisterEvent(e) self.events[e]=true end
        function methods:SetScript(e,f) self.scripts[e]=f end
        function methods:GetChecked() return self.checked end
        function methods:SetChecked(v) self.checked=v end
        function methods:IsShown() return self.shown end
        function methods:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
        function methods:Hide() self.shown=false end
        function methods:CreateFontString() return CreateFrame('FontString') end
        function methods:CreateTexture() return CreateFrame('Texture') end
        function CreateFrame(kind,name,parent,template)
            local f=setmetatable({kind=kind,name=name,parent=parent,template=template,events={},scripts={}}, {__index=methods})
            if template=='BasicFrameTemplateWithInset' then f.TitleText=CreateFrame('FontString') end
            if name then _G[name]=f end
            frames[#frames+1]=f
            return f
        end
        UIParent=CreateFrame('Frame'); GameTooltip=CreateFrame('Tooltip')
        function UnitExists(u) return units[u]~=nil end
        function UnitGUID(u) return units[u] and units[u].guid end
        function UnitName(u) local p=units[u]; if p then return p.name,p.realm end end
        UnitFullName=UnitName
        function UnitRace() return 'Gnome','Gnome' end
        function UnitSex() return 3 end
        function GetNormalizedRealmName() return 'Home' end
        function GetPlayerInfoByGUID() return 'Warrior','WARRIOR','Gnome','Gnome',3 end
        function IsInGroup() return grouped end
        function IsInRaid() return false end
        function UnitInParty(u) return u:match('^party')~=nil end
        function GetTime() return now end
        function PlaySoundFile(id) sounds[#sounds+1]=id; return true,#sounds end
        function StopSound(id) stopped[#stopped+1]=id end
        function SendChatMessage(text) sent[#sent+1]=text end
        function DoEmote(token) if emoteHook then emoteHook(token) end end
        function hooksecurefunc(_,fn) emoteHook=fn end
        C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
        function flush() local pending=timers; timers={}; for _,f in ipairs(pending) do f() end end
        function upvalue(fn,key)
            for i=1,100 do local k,v=debug.getupvalue(fn,i); if k==key then return v end; if not k then break end end
        end
        function event(kind,text,sender,guid)
            for _,f in ipairs(frames) do if f.events[kind] then
                f.scripts.OnEvent(f,kind,text,sender,nil,nil,nil,nil,nil,nil,nil,nil,nil,guid)
            end end
        end
    ''')
    ns=lua.table()
    for name in ('Locales.lua','RoarForever.lua','Options.lua'):
        lua.execute((ROOT/name).read_text(encoding='utf-8'), 'RoarForever', ns)
    lua.globals().RF=ns
    if saved: lua.execute(saved)
    lua.execute("for _,f in ipairs(frames) do if f.events.CHAT_MSG_TEXT_EMOTE then handler=f.scripts.OnEvent end end")
    return lua,ns

count=0
for locale in ('enUS','deDE','frFR','esES','ruRU','enGB','esMX'):
    lua,ns=boot(locale)
    detect=lua.eval("upvalue(handler,'DetectEmote')")
    for _,row in ns.locale.templates.items():
        text=row[2]
        text=re.sub(r'\|3-\d\((.*?)\)',r'\1',text).replace('|2 ', 'de ')
        text=re.sub(r'%(?:[12]\$)?s','Alice',text)
        result=detect(text,'CHAT_MSG_TEXT_EMOTE','Alice')
        assert result==row[1], (locale,text,row[1],result)
        count+=1
    ns.OpenOptions()
    assert len(lua.globals().RoarForeverOptions.rows)==0  # keyed table, checked below
    assert sum(1 for _ in lua.globals().RoarForeverOptions.rows.items())==20

lua,ns=boot()
lua.execute('''
local detect=upvalue(handler,'DetectEmote')
assert(detect('Other checks her mana potions.','CHAT_MSG_EMOTE','Other')==nil)
assert(detect('Other roars with laughter.','CHAT_MSG_EMOTE','Other')==nil)
assert(detect('Other checks her mana potions.','CHAT_MSG_TEXT_EMOTE','Other')==nil)
assert(detect('Other congratulates Dingle.','CHAT_MSG_TEXT_EMOTE','Other')==nil)
assert(detect('Other congratulates Alice.','CHAT_MSG_TEXT_EMOTE','Other')=='congrats')
assert(detect('Other blows a train whistle. Choo choo!','CHAT_MSG_EMOTE','Other')=='train')
assert(detect('Other discusses a train whistle.','CHAT_MSG_EMOTE','Other')==nil)
local isSelf=upvalue(handler,'IsLocalPlayer')
assert(not isSelf('Tester-Away','Player-other'))
assert(not isSelf('Tester-Away',nil))
assert(isSelf('Tester-Home',nil))
assert(isSelf('Different display name','Player-self'))
event('CHAT_MSG_TEXT_EMOTE','Other cheers!','Other','Player-other'); assert(#sounds==1)
event('CHAT_MSG_TEXT_EMOTE','Other cheers!','Other','Player-other'); assert(#sounds==1)
now=101; RF.SettingsDB().emotes.cheer=false
event('CHAT_MSG_TEXT_EMOTE','Other cheers!','Other','Player-other'); assert(#sounds==1)
RF.SetAddonEnabled(false); now=102
event('CHAT_MSG_TEXT_EMOTE','Other roars with bestial vigor. So fierce!','Other','Player-other'); assert(#sounds==1)
-- Preview works even while automatic playback is disabled and sends no chat.
RF.Preview('cheer'); RF.Preview('joke'); assert(#sounds==3 and #stopped==1 and #sent==0)
local pools=upvalue(RF.Preview,'previewPools')
assert(#pools.joke>60 and #pools.cheer>16)
RF.OpenOptions()
local panel=RoarForeverOptions
assert(panel.master.checked==false and panel.rows.cheer.checked==false)
panel.rows.cheer.checked=true; panel.rows.cheer.scripts.OnClick(panel.rows.cheer)
assert(RF.EmoteEnabled('cheer'))
panel.master.checked=true; panel.master.scripts.OnClick(panel.master)
assert(RF.AddonEnabled())
panel.announce.checked=false; panel.announce.scripts.OnClick(panel.announce)
SlashCmdList.ROARFOREVERTRAIN(); flush(); assert(#sent==0)
panel.announce.checked=true; panel.announce.scripts.OnClick(panel.announce)
SlashCmdList.ROARFOREVERTRAIN(); flush(); assert(#sent==1) -- hook and slash coalesced
now=104; RF.SettingsDB().emotes.train=false
SlashCmdList.ROARFOREVERTRAIN(); flush(); assert(#sent==1)
grouped=true; units.party1={name='Friend',realm='Home',guid='Player-friend'}
now=105; event('CHAT_MSG_TEXT_EMOTE','Friend cheers!','Friend','Player-friend'); assert(#sounds==3)
units.target={name='Friend',realm='Away',guid='Player-stranger'}
now=106; event('CHAT_MSG_TEXT_EMOTE','Friend cheers!','Friend','Player-stranger'); assert(#sounds==4)
''')
# Saved options load after the addon files: no eager defaults overwrite them.
lua,ns=boot(saved="RoarForeverDB={enabled=false,emotes={joke=false},announceTrain=false,existing='kept'}")
assert not ns.AddonEnabled() and not ns.EmoteEnabled('joke') and ns.EmoteEnabled('roar')
assert ns.SettingsDB().existing=='kept' and not ns.SettingsDB().announceTrain
lua.execute('''
RF.OpenOptions()
for key,row in pairs(RoarForeverOptions.rows) do
    row.checked=false; row.scripts.OnClick(row)
    assert(RF.SettingsDB().emotes[key]==false)
end
local before=#sounds
for _,f in ipairs(frames) do
    if f.kind=='Button' and f.scripts.OnEnter then f.scripts.OnClick(f) end
end
assert(#sounds==before+20 and #sent==0)
RoarForeverDB=true
assert(RF.AddonEnabled() and RF.EmoteEnabled('joke'))
''')
print(f'PASS: {count} translated template cases, 7 locale variants, menu callbacks, saved options, preview pool, train controls, identity and detection regressions.')
