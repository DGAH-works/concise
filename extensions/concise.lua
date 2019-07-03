--[[
	太阳神三国杀武将扩展包·简约风
	适用版本：V2 - 愚人版（版本号：20150401）清明补丁（版本号：20150405）
	武将总数：8
	武将一览：
		1、清雅（清雅）
		2、静谧（静谧）
		3、恬淡（恬淡）
		4、自然（自然）
		5、空灵（空灵）
		6、高洁（高洁）
		7、幽深（幽深）
		8、祥和（祥和）
]]--
module("extensions.concise", package.seeall)
extension = sgs.Package("concise", sgs.Package_GeneralPack)
--翻译信息
sgs.LoadTranslationTable{
	["concise"] = "简约风",
}
--[[****************************************************************
	编号：^_^ - 001
	武将：清雅
	称号：温婉的坚持
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
ConXiaoYa = sgs.General(extension, "xiao^_^ya", "wei", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^ya"] = "清雅",
	["&xiao^_^ya"] = "清雅",
	["#xiao^_^ya"] = "温婉的坚持",
	["designer:xiao^_^ya"] = "DGAH",
	["cv:xiao^_^ya"] = "无",
	["illustrator:xiao^_^ya"] = "昵图网",
	["~xiao^_^ya"] = "清雅 的阵亡台词",
}
--[[
	技能：清雅
	描述：一名角色的体力变化时，你可以令其摸一张牌或弃一张牌。
	状态：验证通过
]]--
ConQingYa = sgs.CreateTriggerSkill{
	name = "ConQingYa",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpChanged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,source in sgs.qlist(alives) do
			if source:hasSkill("ConQingYa") and player:isAlive() then
				local choices = {player:getGeneralName(), "draw"}
				if not player:isNude() then
					table.insert(choices, "discard")
				end
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local ai_data = sgs.QVariant() -- For AI
				ai_data:setValue(player) -- For AI
				while true do
					room:setPlayerFlag(player, "AI_ConQingYa_Target")
					local choice = room:askForChoice(source, "ConQingYa", choices, ai_data)
					room:setPlayerFlag(player, "-AI_ConQingYa_Target")
					if choice == "draw" then
						room:broadcastSkillInvoke("ConQingYa", 1) --播放配音
						room:notifySkillInvoked(source, "ConQingYa") --显示技能发动
						room:drawCards(player, 1, "ConQingYa")
						break
					elseif choice == "discard" then
						room:broadcastSkillInvoke("ConQingYa", 2) --播放配音
						room:notifySkillInvoked(source, "ConQingYa") --显示技能发动
						local prompt = string.format("@ConQingYa:%s::%s", source:objectName(), "ConQingYa")
						room:askForDiscard(player, "ConQingYa", 1, 1, false, true, prompt)
						break
					elseif choice == "cancel" then
						break
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
ConXiaoYa:addSkill(ConQingYa)
--翻译信息
sgs.LoadTranslationTable{
	["ConQingYa"] = "清雅",
	[":ConQingYa"] = "一名角色的体力变化时，你可以令其摸一张牌或弃一张牌。",
	["$ConQingYa1"] = "技能 清雅 摸牌时 的台词。",
	["$ConQingYa2"] = "技能 清雅 弃牌时 的台词。",
	["@ConQingYa"] = "%src 对您发动了“%arg”，请弃一张牌（包括装备）",
}
--[[****************************************************************
	编号：^_^ - 002
	武将：静谧
	称号：无言的结局
	势力：蜀
	性别：女
	体力上限：4勾玉
]]--****************************************************************
ConXiaoJing = sgs.General(extension, "xiao^_^jing", "shu", 4, false)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^jing"] = "静谧",
	["&xiao^_^jing"] = "静谧",
	["#xiao^_^jing"] = "无言的结局",
	["designer:xiao^_^jing"] = "DGAH",
	["cv:xiao^_^jing"] = "无",
	["illustrator:xiao^_^jing"] = "网络资源",
	["~xiao^_^jing"] = "静谧 的阵亡台词",
}
--[[
	技能：静谧
	描述：回合结束时，你可以展示一张红心花色的手牌，令一名角色失去一点体力。
	状态：验证通过
]]--
ConJingMiCard = sgs.CreateSkillCard{
	name = "ConJingMiCard",
	target_fixed = false,
	will_throw = false,
	skill_name = "ConJingMi",
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConJingMi") --播放配音
		room:notifySkillInvoked(source, "ConJingMi") --显示技能发动
		local subcards = self:getSubcards()
		local id = subcards:first()
		room:showCard(source, id)
		local thread = room:getThread()
		thread:delay()
		local target = targets[1]
		room:loseHp(target, 1)
	end,
}
ConJingMiVS = sgs.CreateViewAsSkill{
	name = "ConJingMi",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:getSuit() == sgs.Card_Heart then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = ConJingMiCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@ConJingMi"
	end,
}
ConJingMi = sgs.CreateTriggerSkill{
	name = "ConJingMi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = ConJingMiVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:isKongcheng() then
				return false
			end
			local room = player:getRoom()
			room:askForUseCard(player, "@@ConJingMi", "@ConJingMi")
		end
		return false
	end,
}
--添加技能
ConXiaoJing:addSkill(ConJingMi)
--翻译信息
sgs.LoadTranslationTable{
	["ConJingMi"] = "静谧",
	[":ConJingMi"] = "回合结束时，你可以展示一张红心花色的手牌，令一名角色失去一点体力。",
	["$ConJingMi"] = "技能 静谧 的台词。",
	["@ConJingMi"] = "您可以发动技能“静谧”",
	["~ConJingMi"] = "选择一张红心花色的手牌->选择一名角色->点击“确定”",
}
--[[****************************************************************
	编号：^_^ - 003
	武将：恬淡
	称号：生命中的舍弃
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
ConXiaoTian = sgs.General(extension, "xiao^_^tian", "wu", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^tian"] = "恬淡",
	["&xiao^_^tian"] = "恬淡",
	["#xiao^_^tian"] = "生命中的舍弃",
	["designer:xiao^_^tian"] = "DGAH",
	["cv:xiao^_^tian"] = "无",
	["illustrator:xiao^_^tian"] = "网络资源",
	["~xiao^_^tian"] = "恬淡 的阵亡台词",
}
--[[
	技能：恬淡
	描述：当你成为一张卡牌的目标时，你可以弃置一名角色的一张牌。 
	状态：验证通过
]]--
ConTianDan = sgs.CreateTriggerSkill{
	name = "ConTianDan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local card = use.card
		if card and not card:isKindOf("SkillCard") then
			local can_invoke = false
			for _,p in sgs.qlist(use.to) do
				if p:objectName() == player:objectName() then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				local room = player:getRoom()
				local targets = sgs.SPlayerList()
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if not p:isNude() then
						targets:append(p)
					end
				end
				if targets:isEmpty() then
					return false
				end
				local target = room:askForPlayerChosen(player, targets, "ConTianDan", "@ConTianDan", true, true)
				if target then
					local id = room:askForCardChosen(player, target, "he", "ConTianDan")
					if id > 0 then
						if player:canDiscard(target, id) then
							room:broadcastSkillInvoke("ConTianDan") --播放配音
							room:throwCard(id, target, source)
						else
							local msg = sgs.LogMessage()
							msg.type = "#ConTianDanFailed"
							msg.from = player
							msg.to:append(target)
							msg.arg = "ConTianDan"
							msg.arg2 = id
							room:sendLog(msg) --发送提示信息
						end
					end
				end
			end
		end
		return false
	end,
}
--添加技能
ConXiaoTian:addSkill(ConTianDan)
--翻译信息
sgs.LoadTranslationTable{
	["ConTianDan"] = "恬淡",
	[":ConTianDan"] = "当你成为一张卡牌的目标时，你可以弃置一名角色的一张牌。 ",
	["$ConTianDan"] = "技能 恬淡 的台词。",
	["@ConTianDan"] = "您可以发动技能“恬淡”弃置一名角色的一张牌",
	["#ConTianDanFailed"] = "%from 对 %to 发动了技能“%arg”，但选出的卡牌（ID：%arg2）不能被弃置",
}
--[[****************************************************************
	编号：^_^ - 004
	武将：自然
	称号：积累的成果
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ConXiaoRan = sgs.General(extension, "xiao^_^ran", "shu", 4, true)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^ran"] = "自然",
	["&xiao^_^ran"] = "自然",
	["#xiao^_^ran"] = "积累的成果",
	["designer:xiao^_^ran"] = "DGAH",
	["cv:xiao^_^ran"] = "无",
	["illustrator:xiao^_^ran"] = "昵图网",
	["~xiao^_^ran"] = "自然 的阵亡台词",
}
--[[
	技能：自然（阶段技）
	描述：你可以获得一名角色区域中的一张牌。 
	状态：验证通过
]]--
ConZiRanCard = sgs.CreateSkillCard{
	name = "ConZiRanCard",
	target_fixed = false,
	will_throw = true,
	skill_name = "ConZiRan",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return not to_select:isAllNude()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConZiRan") --播放配音
		room:notifySkillInvoked(source, "ConZiRan") --显示技能发动
		local target = targets[1]
		local id = room:askForCardChosen(source, target, "hej", "ConZiRan")
		if id > 0 then
			room:obtainCard(source, id)
		end
	end,
}
ConZiRan = sgs.CreateViewAsSkill{
	name = "ConZiRan",
	n = 0,
	view_as = function(self, cards)
		return ConZiRanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ConZiRanCard")
	end,
}
--添加技能
ConXiaoRan:addSkill(ConZiRan)
--翻译信息
sgs.LoadTranslationTable{
	["ConZiRan"] = "自然",
	[":ConZiRan"] = "<font color=\"green\"><b>阶段技</b></font>, 你可以获得一名角色区域中的一张牌。 ",
	["$ConZiRan"] = "技能 自然 的台词",
}
--[[****************************************************************
	编号：^_^ - 005
	武将：空灵
	称号：倾听烦恼
	势力：群
	性别：女
	体力上限：4勾玉
]]--****************************************************************
ConXiaoLing = sgs.General(extension, "xiao^_^ling", "qun", 4, false)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^ling"] = "空灵",
	["&xiao^_^ling"] = "空灵",
	["#xiao^_^ling"] = "倾听烦恼",
	["designer:xiao^_^ling"] = "DGAH",
	["cv:xiao^_^ling"] = "无",
	["illustrator:xiao^_^ling"] = "网络资源",
	["~xiao^_^ling"] = "空灵 的阵亡台词",
}
--[[
	技能：空灵（阶段技）
	描述：你可以展示一名角色的所有手牌，选择其中一张弃置之。
	状态：验证通过
]]--
ConKongLingCard = sgs.CreateSkillCard{
	name = "ConKongLingCard",
	target_fixed = false,
	will_throw = true,
	skill_name = "ConKongLing",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return not to_select:isKongcheng()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConKongLing") --播放配音
		room:notifySkillInvoked(source, "ConKongLing") --显示技能发动
		local target = targets[1]
		local handcard_ids = target:handCards()
		if handcard_ids:isEmpty() then
			return 
		end
		room:fillAG(handcard_ids)
		local id = room:askForAG(source, handcard_ids, true, "ConKongLing")
		room:clearAG()
		if id > 0 then
			room:throwCard(id, target, source)
		end
		for _,id in sgs.qlist(handcard_ids) do
			room:setCardFlag(id, "visible")
		end
	end,
}
ConKongLing = sgs.CreateViewAsSkill{
	name = "ConKongLing",
	n = 0,
	view_as = function(self, cards)
		return ConKongLingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ConKongLingCard")
	end,
}
--添加技能
ConXiaoLing:addSkill(ConKongLing)
--翻译信息
sgs.LoadTranslationTable{
	["ConKongLing"] = "空灵",
	[":ConKongLing"] = "<font color=\"green\"><b>阶段技</b></font>, 你可以展示一名角色的所有手牌，选择其中一张弃置之。",
	["$ConKongLing"] = "技能 空灵 的台词",
}
--[[****************************************************************
	编号：^_^ - 006
	武将：高洁
	称号：灵魂的安抚
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ConXiaoJie = sgs.General(extension, "xiao^_^jie", "qun", 4, true)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^jie"] = "高洁",
	["&xiao^_^jie"] = "高洁",
	["#xiao^_^jie"] = "灵魂的安抚",
	["designer:xiao^_^jie"] = "DGAH",
	["cv:xiao^_^jie"] = "无",
	["illustrator:xiao^_^jie"] = "网络资源",
	["~xiao^_^jie"] = "高洁 的阵亡台词",
}
--[[
	技能：高洁（阶段技）
	描述：你可以令一名角色回复一点体力。
	状态：验证通过
]]--
ConGaoJieCard = sgs.CreateSkillCard{
	name = "ConGaoJieCard",
	target_fixed = false,
	will_throw = true,
	skill_name = "ConGaoJie",
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:isWounded()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConGaoJie") --播放配音
		room:notifySkillInvoked(source, "ConGaoJie") --显示技能发动
		local target = targets[1]
		local recover = sgs.RecoverStruct()
		recover.who = source
		recover.recover = 1
		room:recover(target, recover, true)
	end,
}
ConGaoJie = sgs.CreateViewAsSkill{
	name = "ConGaoJie",
	n = 0,
	view_as = function(self, cards)
		return ConGaoJieCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ConGaoJieCard")
	end,
}
--添加技能
ConXiaoJie:addSkill(ConGaoJie)
--翻译信息
sgs.LoadTranslationTable{
	["ConGaoJie"] = "高洁",
	[":ConGaoJie"] = "<font color=\"green\"><b>阶段技</b></font>, 你可以令一名角色回复一点体力。",
	["$ConGaoJie"] = "技能 高洁 的台词。",
}
--[[****************************************************************
	编号：^_^ - 007
	武将：幽深
	称号：长路漫漫
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ConXiaoYou = sgs.General(extension, "xiao^_^you", "wei", 4, true)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^you"] = "幽深",
	["&xiao^_^you"] = "幽深",
	["#xiao^_^you"] = "长路漫漫",
	["designer:xiao^_^you"] = "DGAH",
	["cv:xiao^_^you"] = "无",
	["illustrator:xiao^_^you"] = "昵图网",
	["~xiao^_^you"] = "幽深 的阵亡台词",
}
--[[
	技能：幽深（阶段技）
	描述：你可以弃一张黑桃花色的手牌，令一名角色翻面。
	状态：验证通过
]]--
ConYouShenCard = sgs.CreateSkillCard{
	name = "ConYouShenCard",
	target_fixed = false,
	will_throw = true,
	skill_name = "ConYouShen",
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConYouShen") --播放配音
		room:notifySkillInvoked(source, "ConYouShen") --显示技能发动
		local target = targets[1]
		target:turnOver()
	end,
}
ConYouShen = sgs.CreateViewAsSkill{
	name = "ConYouShen",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:getSuit() == sgs.Card_Spade then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = ConYouShenCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ConYouShenCard")
	end,
}
--添加技能
ConXiaoYou:addSkill(ConYouShen)
--翻译信息
sgs.LoadTranslationTable{
	["ConYouShen"] = "幽深",
	[":ConYouShen"] = "<font color=\"green\"><b>阶段技</b></font>, 你可以弃一张黑桃花色的手牌，令一名角色翻面。",
	["$ConYouShen"] = "技能 幽深 的台词。",
}
--[[****************************************************************
	编号：^_^ - 008
	武将：祥和
	称号：悲喜人生
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
ConXiaoXiang = sgs.General(extension, "xiao^_^xiang", "wu", 4, true)
--翻译信息
sgs.LoadTranslationTable{
	["xiao^_^xiang"] = "祥和",
	["&xiao^_^xiang"] = "祥和",
	["#xiao^_^xiang"] = "悲喜人生",
	["designer:xiao^_^xiang"] = "DGAH",
	["cv:xiao^_^xiang"] = "无",
	["illustrator:xiao^_^xiang"] = "昵图网",
	["~xiao^_^xiang"] = "祥和 的阵亡台词",
}
--[[
	技能：祥和（阶段技）
	描述：你可以摸一张牌，然后令一名角色弃一张牌。
	状态：验证通过
]]--
ConXiangHeCard = sgs.CreateSkillCard{
	name = "ConXiangHeCard",
	target_fixed = true,
	will_throw = true,
	skill_name = "ConXiangHe",
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("ConXiangHe", 1) --播放配音
		room:notifySkillInvoked(source, "ConXiangHe") --显示技能发动
		room:drawCards(source, 1, "ConXiangHe")
		local victims = sgs.SPlayerList()
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if not p:isNude() then
				victims:append(p)
			end
		end
		if victims:isEmpty() then
			return
		end
		local target = room:askForPlayerChosen(source, victims, "ConXiangHe", "@ConXiangHe", true, false)
		if target then
			room:broadcastSkillInvoke("ConXiangHe", 2) --播放配音
			local prompt = string.format("@ConXiangHeDiscard:%s::%s:", source:objectName(), "ConXiangHe")
			room:askForDiscard(target, "ConXiangHe", 1, 1, false, true, prompt)
		end
	end,
}
ConXiangHe = sgs.CreateViewAsSkill{
	name = "ConXiangHe",
	n = 0,
	view_as = function(self, cards)
		return ConXiangHeCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ConXiangHeCard")
	end,
}
--添加技能
ConXiaoXiang:addSkill(ConXiangHe)
--翻译信息
sgs.LoadTranslationTable{
	["ConXiangHe"] = "祥和",
	[":ConXiangHe"] = "<font color=\"green\"><b>阶段技</b></font>, 你可以摸一张牌，然后令一名角色弃一张牌。",
	["$ConXiangHe1"] = "技能 祥和 摸牌时 的台词。",
	["$ConXiangHe2"] = "技能 祥和 弃牌时 的台词。",
	["@ConXiangHe"] = "您可以发动“祥和”令一名角色弃一张牌",
	["@ConXiangHeDiscard"] = "%src 对您发动了技能“%arg”，请弃一张牌（包括装备）",
}