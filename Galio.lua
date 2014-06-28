local version = "1.00"

if myHero.charName ~= "Galio" then return end


local REQUIRED_LIBS = {
  ["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
  ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua"
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
  DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
  if DOWNLOAD_COUNT == 0 then
    DOWNLOADING_LIBS = false
    print("<b><font color=\"#6699FF\">Galio - How do I write these things?:</font></b> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
  end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
  if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
    require(DOWNLOAD_LIB_NAME)
  else
    DOWNLOADING_LIBS = true
    DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
    DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
  end
end

if DOWNLOADING_LIBS then return end


------------------------------------------------------
--       Callbacks        
------------------------------------------------------

function OnLoad()
  print("<b><font color=\"#6699FF\">Galio - How do I write these things?:</font></b> <font color=\"#FFFFFF\">Sucessfully loaded!</font>")
  Variables()
  Menu()
  PriorityOnLoad()
end

function OnTick()
  EnemyMinions:update()
  ComboKey = Settings.combo.comboKey
  HarassKey = Settings.harass.harassKey
  FleeKey = Settings.flee.FleeKey
  JungleClearKey = Settings.jungle.jungleKey
  LaneClearKey = Settings.lane.laneKey
  SmartUltimateKey = Settings.ult.ultKey
  
  if ComboKey then
    Combo(Target)
  end
  
  if HarassKey then
    Harass(Target)
  end
  
  if FleeKey then
    Flee()
  end
  
  if JungleClearKey then
    JungleClear()
  end
  
  if LaneClearKey then
    LaneClear()
  end
  
  if SmartUltimateKey then
    SmartR(Target)
  end
  
  if Settings.ks.killSteal then
    KillSteal()
  end
  
  if Settings.extra.AutoShield then
    AutoW()
  end

  Checks()
end

function OnDraw()
  if not myHero.dead and not Settings.drawing.mDraw then
    if SkillQ.ready and Settings.drawing.qDraw then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0xCE00FF)
    end
    if SkillE.ready and Settings.drawing.eDraw then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, 0xCE00FF)
    end
    if SkillR.ready and Settings.drawing.rDraw then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, 0xCE00FF)
    end
    
    if Settings.drawing.Target and Target ~= nil then
      DrawCircle(Target.x, Target.y, Target.z, 70, 0xCE00FF)
    end
    
    if Settings.drawing.myHero then
      DrawCircle(myHero.x, myHero.y, myHero.z, 125, 0x6699FF)
    end
  end
end

------------------------------------------------------
--       Functions        
------------------------------------------------------

function Combo(unit)
  if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
    if Settings.combo.useQ then CastQ(unit) end
    if Settings.combo.useW then CastW(unit) end
    if Settings.combo.useE then CastE(unit) end
    if Settings.combo.comboItems then UseItems(unit) end
    if Settings.combo.useR then CastR(unit, Settings.combo.minR) end
  end
end

function OnProcessSpell(unit, spell)
        if Settings.extra.SilenceR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and SkillR.ready and GetDistance(unit) < SkillR.range then
                if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel"
                or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp"
                or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole"
                or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" then
                        CastSpell(_R, unit)
                end
        end
end

function Flee()
  Mv = mousePos
  myHero:MoveTo(mousePos.x, mousePos.z)
  if SkillE.ready and Settings.flee.useE then CastSpell(_E, mousePos.x, mousePos.z) end
  if SkillW.ready and Settings.flee.useW then CastSpell(_W) end
end

function Harass(unit)
  if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLow() then
      if Settings.harass.useQ then CastQ(unit) end
      if Settings.harass.useE then CastE(unit) end
  end
end

function LaneClear()
  if not GetJungleMob() then
    for i, minion in pairs(EnemyMinions.objects) do
	if minion and minion.valid and not minion.dead then
        if Settings.lane.laneQ and GetDistance(minion) <= SkillQ.range then CastQ(minion) end
        if Settings.lane.laneE and GetDistance(minion) <= SkillE.range then CastE(minion) end
      end    
    end
  end
end

function JungleClear()
    local JungleMob = GetJungleMob()
    if JungleMob ~= nil then
      if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range then CastQ(JungleMob) end
      if Settings.jungle.jungleE and GetDistance(JungleMob) <= SkillE.range then CastE(JungleMob) end
    end
end

function AutoW()
  local NowHp = myHero.health
  if (NowHp+(Settings.extra.HPloss) < ThenHp) then
    if SkillW.ready then
      CastSpell(_W)
    end   
  end
  ThenHp = NowHp  
end

function CastQ(unit)
  if SkillQ.ready and GetDistance(unit) <= SkillQ.range then
    local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero) 
    if HitChance >= 2 then CastSpell(_Q, CastPosition.x, CastPosition.z) end
  end  
end

function CastE(unit)
  if SkillE.ready and GetDistance(unit) <= SkillE.range then
    local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SkillE.delay, SkillE.width, SkillE.range, SkillE.speed, myHero) 
    if HitChance >= 2 then CastSpell(_E, CastPosition.x, CastPosition.z) end
  end  
end

function ChaseE(unit)
  if SkillE.ready and GetDistance(unit) <= SkillE.range+600 then
    local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SkillE.delay, SkillE.width, SkillE.range, SkillE.speed, myHero) 
    CastSpell(_E, CastPosition.x, CastPosition.z)
  end  
end

function CastW(unit)
    if SkillW.ready and GetDistance(unit) <= SkillE.range then
      CastSpell(_W)
    end
end

function CastR(unit, count)
    if SkillR.ready and AreaEnemyCount(myHero, SkillR.range) >= count then
      CastSpell(_R)
    end
end

function SmartR(unit)
  if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and SkillR.ready then
    AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(unit, SkillR.delay, SkillR.width, 2000+SkillR.range, 325, myHero)
    myHero:MoveTo(AOECastPosition.x, AOECastPosition.z) 
    CastR(unit, Settings.ult.minR)
  end
end

function AreaEnemyCount(Spot, Range)
  local count = 0
  for _, enemy in pairs(GetEnemyHeroes()) do
    if enemy and not enemy.dead and enemy.visible and GetDistance(Spot, enemy) <= Range then
      count = count + 1
    end
  end            
  return count
end

function KillSteal()
  for _, enemy in ipairs(GetEnemyHeroes()) do
    qDmg = getDmg("Q", enemy, myHero)
    eDmg = getDmg("E", enemy, myHero)
    
    if ValidTarget(enemy) and enemy.visible then
      if enemy.health <= qDmg then
        CastQ(enemy)
      elseif enemy.health <= qDmg + eDmg then
        CastE(enemy)
        CastQ(enemy)
      elseif enemy.health <= eDmg then
        CastE(enemy)
      end

      if Settings.ks.autoIgnite then
        AutoIgnite(enemy)
      end
    end
  end
end

function AutoIgnite(unit)
  if ValidTarget(unit, Ignite.range) and unit.health <= 50 + (20 * myHero.level) then
    if Ignite.ready then
      CastSpell(Ignite.slot, unit)
    end
  end
end

------------------------------------------------------
--       Checks, menu & stuff       
------------------------------------------------------

function Checks()
  SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
  SkillW.ready = (myHero:CanUseSpell(_W) == READY)
  SkillE.ready = (myHero:CanUseSpell(_E) == READY)
  SkillR.ready = (myHero:CanUseSpell(_R) == READY)
  
  if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
    Ignite.slot = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
    Ignite.slot = SUMMONER_2
  end
  
  Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
  
  TargetSelector:update()
  Target = TargetSelector.target
  SOWi:ForceTarget(Target)
end

function IsMyManaLow()
  if myHero.mana < (myHero.maxMana * ( Settings.harass.harassMana / 100)) then
    return true
  else
    return false
  end
end

function Menu()
  Settings = scriptConfig("Galio - the Sentinel's Sorrow "..version.."", "iDyL Karthus")
  
  Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
    Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_ONOFF, true)
    Settings.combo:addParam("minR", "Min Enemys for (R)", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Settings.combo:addParam("useQ", "Use "..SkillQ.name.." (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
    Settings.combo:addParam("useW", "Use "..SkillW.name.." (W) Always in Combo", SCRIPT_PARAM_ONOFF, false)
    Settings.combo:addParam("useE", "Use "..SkillE.name.." (E) in Combo", SCRIPT_PARAM_ONOFF, true)
    Settings.combo:addParam("chaseE", "Use "..SkillE.name.." (E) to chase", SCRIPT_PARAM_ONOFF, true)
    Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
    Settings.combo:permaShow("comboKey")
  
  Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
    Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
    Settings.harass:addParam("harassMode", "Choose Harass Mode", SCRIPT_PARAM_LIST, 1, { "Q + E", "Q" })
    Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
    Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, false)
    Settings.harass:addParam("useE", "Use "..SkillE.name.." (E) in Harass", SCRIPT_PARAM_ONOFF, true)
    Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Settings.harass:permaShow("harassKey")
    
  Settings:addSubMenu("["..myHero.charName.."] - Flee Settings", "flee")
    Settings.flee:addParam("FleeKey", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
    Settings.flee:addParam("useW", "Use "..SkillW.name.." (W) in Flee", SCRIPT_PARAM_ONOFF, true)
    Settings.flee:addParam("useE", "Use "..SkillE.name.." (E) in Flee", SCRIPT_PARAM_ONOFF, true)
    Settings.flee:permaShow("fleeKey")
    
  Settings:addSubMenu("["..myHero.charName.."] - Smart Ultimate Settings", "ult")
    Settings.ult:addParam("ultKey", "Smart Ult Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
    Settings.ult:addParam("minR", "Min Enemys for (R)", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Settings.ult:addParam("moveR", "Max Distance to try to move", SCRIPT_PARAM_SLICE, 1000, 0, 2000, 0)
    Settings.ult:permaShow("ultKey")
    
  Settings:addSubMenu("["..myHero.charName.."] - Extra Settings", "extra")
    Settings.extra:addParam("AutoShield", "Auto use "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
    Settings.extra:addParam("HPloss", "min HP loss to activate shield", SCRIPT_PARAM_SLICE, 10, 0, 200, 0)
    Settings.extra:addParam("SilenceR", "use "..SkillR.name.." (R) to stop spells", SCRIPT_PARAM_ONOFF, true)
    Settings.extra:permaShow("AutoShield")
    
  Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
    Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Settings.lane:addParam("laneQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
    Settings.lane:addParam("laneE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
    Settings.lane:permaShow("laneKey")
    
  Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
    Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
    Settings.jungle:addParam("jungleE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
    Settings.jungle:permaShow("jungleKey")
    
  Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
    Settings.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
    Settings.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
    Settings.ks:permaShow("killSteal")
      
  Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing") 
    Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
    Settings.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
    Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, false)
    Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
    Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
    Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
  Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
    SOWi:LoadToMenu(Settings.Orbwalking)
  
  TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, SkillW.range, DAMAGE_MAGIC, true)
  TargetSelector.name = "Galio"
  Settings:addTS(TargetSelector)
end

function Variables()
  SkillQ = { name = "Resolute Smite", range = 940, delay = 0.5, speed = 1300, width = 120, ready = false }
  SkillW = { name = "Bulwark", range = 800, delay = nil, speed = nil, width = nil, ready = false }
  SkillE = { name = "Righteous Gust", range = 1180, delay = 0.5, speed = 1200, width = 140, ready = false }
  SkillR = { name = "Idol of Durand", range = 600, delay = 0.5, speed = nil, width = 300, ready = false }
  Ignite = { name = "SummonerDot", range = 600, slot = nil }
  ThenHp = myHero.health
  
  EnemyMinions = minionManager(MINION_ENEMY, SkillQ.range, myHero, MINION_SORT_HEALTH_ASC)
  
  VP = VPrediction()
  SOWi = SOW(VP)
  
  JungleMobs = {}
  JungleFocusMobs = {}
  
  priorityTable = {
      AP = {
        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
        "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
      },
      
      Support = {
        "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
      },
      
      Tank = {
        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
        "Warwick", "Yorick", "Zac"
      },
      
      AD_Carry = {
        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
        "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
      },
      
      Bruiser = {
        "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
        "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
      }
  }

  Items = {
    BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
    BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
    DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
    HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
    RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
    STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
    TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
    YGB = { id = 3142, range = 350, reqTarget = false, slot = nil }
  }
  
  JungleMobNames = { 
    ["Wolf8.1.2"]     = true,
    ["Wolf8.1.3"]     = true,
    ["YoungLizard7.1.2"]  = true,
    ["YoungLizard7.1.3"]  = true,
    ["LesserWraith9.1.3"] = true,
    ["LesserWraith9.1.2"] = true,
    ["LesserWraith9.1.4"] = true,
    ["YoungLizard10.1.2"] = true,
    ["YoungLizard10.1.3"] = true,
    ["SmallGolem11.1.1"]  = true,
    ["Wolf2.1.2"]     = true,
    ["Wolf2.1.3"]     = true,
    ["YoungLizard1.1.2"]  = true,
    ["YoungLizard1.1.3"]  = true,
    ["LesserWraith3.1.3"] = true,
    ["LesserWraith3.1.2"] = true,
    ["LesserWraith3.1.4"] = true,
    ["YoungLizard4.1.2"]  = true,
    ["YoungLizard4.1.3"]  = true,
    ["SmallGolem5.1.1"]   = true
  }
  
  FocusJungleNames = {
    ["Dragon6.1.1"]     = true,
    ["Worm12.1.1"]      = true,
    ["GiantWolf8.1.1"]    = true,
    ["AncientGolem7.1.1"] = true,
    ["Wraith9.1.1"]     = true,
    ["LizardElder10.1.1"] = true,
    ["Golem11.1.2"]     = true,
    ["GiantWolf2.1.1"]    = true,
    ["AncientGolem1.1.1"] = true,
    ["Wraith3.1.1"]     = true,
    ["LizardElder4.1.1"]  = true,
    ["Golem5.1.2"]      = true,
    ["GreatWraith13.1.1"] = true,
    ["GreatWraith14.1.1"] = true
  }
    
  for i = 0, objManager.maxObjects do
    local object = objManager:getObject(i)
    if object and object.valid and not object.dead then
      if FocusJungleNames[object.name] then
        JungleFocusMobs[#JungleFocusMobs+1] = object
      elseif JungleMobNames[object.name] then
        JungleMobs[#JungleMobs+1] = object
      end
    end
  end
end

function SetPriority(table, hero, priority)
  for i=1, #table, 1 do
    if hero.charName:find(table[i]) ~= nil then
      TS_SetHeroPriority(priority, hero.charName)
    end
  end
end
 
function arrangePrioritys()
        for i, enemy in ipairs(GetEnemyHeroes()) do
    SetPriority(priorityTable.AD_Carry, enemy, 1)
    SetPriority(priorityTable.AP,       enemy, 2)
    SetPriority(priorityTable.Support,  enemy, 3)
    SetPriority(priorityTable.Bruiser,  enemy, 4)
    SetPriority(priorityTable.Tank,     enemy, 5)
        end
end

function UseItems(unit)
  if unit ~= nil then
    for _, item in pairs(Items) do
      item.slot = GetInventorySlotItem(item.id)
      if item.slot ~= nil then
        if item.reqTarget and GetDistance(unit) < item.range then
          CastSpell(item.slot, unit)
        elseif not item.reqTarget then
          if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
            CastSpell(item.slot)
          end
        end
      end
    end
  end
end

function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end

function PriorityOnLoad()
  if heroManager.iCount < 10 then
    print("<b><font color=\"#6699FF\">Galio - the Sentinel's Sorrow:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
  else
    arrangePrioritys()
    end
end

function GetJungleMob()
  for _, Mob in pairs(JungleFocusMobs) do
    if ValidTarget(Mob, SkillQ.range) then return Mob end
  end
  for _, Mob in pairs(JungleMobs) do
    if ValidTarget(Mob, SkillQ.range) then return Mob end
  end
end

function OnCreateObj(obj)
  if obj.valid then
    if FocusJungleNames[obj.name] then
      JungleFocusMobs[#JungleFocusMobs+1] = obj
    elseif JungleMobNames[obj.name] then
      JungleMobs[#JungleMobs+1] = obj
    end
  end
end

function OnDeleteObj(obj)
  for i, Mob in pairs(JungleMobs) do
    if obj.name == Mob.name then
      table.remove(JungleMobs, i)
    end
  end
  for i, Mob in pairs(JungleFocusMobs) do
    if obj.name == Mob.name then
      table.remove(JungleFocusMobs, i)
    end
  end
end