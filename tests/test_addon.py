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
        guidRace={['Player-self']='Gnome',['Player-other']='Gnome',['Player-friend']='Gnome',['Player-stranger']='Gnome'}
        function UnitRace(u)
            local p=units[u]; local r=(p and guidRace[p.guid]) or 'Gnome'
            return r,r
        end
        function GetNormalizedRealmName() return 'Home' end
        function GetPlayerInfoByGUID(guid)
            local r=guidRace[guid] or 'Gnome'
            local sex=(guidSex[guid]) or ((r=='Orc' or r=='Human') and 2) or 3
            return 'Warrior','WARRIOR',r,r,sex
        end
        guidSex={}
        function UnitSex(u)
            local p=units[u]
            if p and guidSex[p.guid] then return guidSex[p.guid] end
            local r=p and guidRace[p.guid]
            if r=='Orc' or r=='Human' then return 2 end
            return 3
        end
        playerFaction='Horde'
        function UnitFactionGroup() return playerFaction end
        function IsInGroup() return grouped end
        function IsInRaid() return false end
        function UnitInParty(u) return u:match('^party')~=nil end
        function GetTime() return now end
        function PlaySoundFile(id) sounds[#sounds+1]=id; return true,#sounds end
        function StopSound(id) stopped[#stopped+1]=id end
        function SendChatMessage(text, kind) sent[#sent+1]={text=text, kind=kind or 'SAY'} end
        -- Match production: prefer C_ChatInfo when present (pre-0.5.5 train path).
        C_ChatInfo={SendChatMessage=function(text, kind) sent[#sent+1]={text=text, kind='C_'..(kind or 'SAY')} end}
        doEmoteCallsHook=true
        function DoEmote(token) if doEmoteCallsHook and emoteHook then emoteHook(token) end end
        function hooksecurefunc(_,fn) emoteHook=fn end
        function pcall(fn, ...) return true, fn(...) end
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
    assert sum(1 for _ in lua.globals().RoarForeverOptions.rows.items())==22

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
assert(detect('Other cheers for the Horde! For the Horde!','CHAT_MSG_EMOTE','Other')=='forthehorde')
assert(detect('Other cheers for the Horde!','CHAT_MSG_EMOTE','Other')==nil)
assert(detect('Other yells for the Horde in general.','CHAT_MSG_EMOTE','Other')==nil)
assert(detect('Other cheers for the Alliance! For the Alliance!','CHAT_MSG_EMOTE','Other')=='forthealliance')
assert(detect('Other cheers for the Alliance!','CHAT_MSG_EMOTE','Other')==nil)
assert(detect('Other talks about the Alliance casually.','CHAT_MSG_EMOTE','Other')==nil)
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
SlashCmdList.ROARFOREVERTRAIN(); assert(#sent==1 and sent[1].text=='blows a train whistle. Choo choo!' and sent[1].kind=='C_EMOTE')
now=104; RF.SettingsDB().emotes.train=false
SlashCmdList.ROARFOREVERTRAIN(); assert(#sent==1)
grouped=true; units.party1={name='Friend',realm='Home',guid='Player-friend'}
now=105; event('CHAT_MSG_TEXT_EMOTE','Friend cheers!','Friend','Player-friend'); assert(#sounds==3)
units.target={name='Friend',realm='Away',guid='Player-stranger'}
now=106; event('CHAT_MSG_TEXT_EMOTE','Friend cheers!','Friend','Player-stranger'); assert(#sounds==4)
-- Self/group roar still plays for races without a client roar.
now=107; event('CHAT_MSG_TEXT_EMOTE','You roar with bestial vigor. So fierce!','Tester','Player-self'); assert(#sounds==5)
now=108; event('CHAT_MSG_TEXT_EMOTE','Friend roars with bestial vigor. So fierce!','Friend','Player-friend'); assert(#sounds==6)
-- Skyborne already have a client roar: leave self and group to the game.
guidRace['Player-self']='Skyborne'; guidRace['Player-friend']='Skyborne'
now=109; event('CHAT_MSG_TEXT_EMOTE','You roar with bestial vigor. So fierce!','Tester','Player-self'); assert(#sounds==6)
now=110; event('CHAT_MSG_TEXT_EMOTE','Friend roars with bestial vigor. So fierce!','Friend','Player-friend'); assert(#sounds==6)
-- Nearby non-grouped Skyborne roar is still restored.
guidRace['Player-stranger']='Skyborne'
now=111; event('CHAT_MSG_TEXT_EMOTE','Friend roars with bestial vigor. So fierce!','Friend','Player-stranger'); assert(#sounds==7)
-- /forthehorde: Horde orc plays locally via DoEmote hook; Alliance is refused.
guidRace['Player-self']='Orc'; guidRace['Player-friend']='Orc'; guidRace['Player-stranger']='Orc'; guidRace['Player-other']='Orc'
playerFaction='Alliance'; local beforeSent=#sent; local beforeSounds=#sounds
SlashCmdList.ROARFOREVERFTH(); flush()
assert(#sent==beforeSent and #sounds==beforeSounds)
playerFaction='Horde'; now=112
SlashCmdList.ROARFOREVERFTH()
assert(#sent==beforeSent+1 and sent[#sent].text=='cheers for the Horde! For the Horde!' and sent[#sent].kind=='C_EMOTE')
assert(#sounds==beforeSounds+1 and sounds[#sounds]==1387394)
-- Own announce must not double-play; nearby and grouped others still play.
now=113; event('CHAT_MSG_EMOTE','cheers for the Horde! For the Horde!','Tester','Player-self'); assert(#sounds==beforeSounds+1)
now=114; event('CHAT_MSG_EMOTE','cheers for the Horde! For the Horde!','Other','Player-other'); assert(#sounds==beforeSounds+2)
now=115; event('CHAT_MSG_EMOTE','cheers for the Horde! For the Horde!','Friend','Player-friend'); assert(#sounds==beforeSounds+3)
RF.SetAddonEnabled(false); now=116
SlashCmdList.ROARFOREVERFTH(); assert(#sounds==beforeSounds+3)
RF.SetAddonEnabled(true)
-- /forthealliance: Alliance human plays; Horde is refused.
guidRace['Player-self']='Human'; guidRace['Player-friend']='Human'; guidRace['Player-other']='Human'
playerFaction='Horde'; beforeSent=#sent; beforeSounds=#sounds
SlashCmdList.ROARFOREVERFTA()
assert(#sent==beforeSent and #sounds==beforeSounds)
playerFaction='Alliance'; now=117
SlashCmdList.ROARFOREVERFTA()
assert(#sent==beforeSent+1 and sent[#sent].text=='cheers for the Alliance! For the Alliance!' and sent[#sent].kind=='C_EMOTE')
assert(#sounds==beforeSounds+1 and sounds[#sounds]==1502109)
now=118; event('CHAT_MSG_EMOTE','cheers for the Alliance! For the Alliance!','Tester','Player-self'); assert(#sounds==beforeSounds+1)
now=119; event('CHAT_MSG_EMOTE','cheers for the Alliance! For the Alliance!','Other','Player-other'); assert(#sounds==beforeSounds+2)
now=120; event('CHAT_MSG_EMOTE','cheers for the Alliance! For the Alliance!','Friend','Player-friend'); assert(#sounds==beforeSounds+3)
-- Slash path must still announce when DoEmote is a silent no-op (no hook).
doEmoteCallsHook=false; now=121; beforeSent=#sent; beforeSounds=#sounds
SlashCmdList.ROARFOREVERFTA()
assert(#sent==beforeSent+1 and sent[#sent].kind=='C_EMOTE')
assert(#sounds==beforeSounds+1)
doEmoteCallsHook=true
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
assert(#sounds==before+22 and #sent==0)
RoarForeverDB=true
assert(RF.AddonEnabled() and RF.EmoteEnabled('joke'))
''')
print(f'PASS: {count} translated template cases, 7 locale variants, menu callbacks, saved options, preview pool, train controls, faction cries, Skyborne roar exception, identity and detection regressions.')
