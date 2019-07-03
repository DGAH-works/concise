--[[
	太阳神三国杀武将扩展包·简约风（AI部分）
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
--[[****************************************************************
	编号：^_^ - 001
	武将：清雅
	称号：温婉的坚持
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：清雅
	描述：一名角色的体力变化时，你可以令其摸一张牌或弃一张牌。
	状态：验证通过
]]--
--room:askForChoice(source, "ConQingYa", choices, ai_data)
sgs.ai_skill_choice["ConQingYa"] = function(self, choices, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		if string.find(choices, "draw") then
			if target:isKongcheng() and self:needKongcheng(target) then
			else
				return "draw"
			end
		end
	else
		if string.find(choices, "discard") then
			return "discard"
		end
	end
	return "cancel"
end
--相关信息
sgs.ai_choicemade_filter["skillChoice"].ConQingYa = function(self, player, promptlist)
	local alives = self.room:getAlivePlayers()
	local target = nil
	for _,p in sgs.qlist(alives) do
		if p:hasFlag("AI_ConQingYa_Target") then
			target = p
			break
		end
	end
	if target and target:objectName() ~= player:objectName() then
		local choice = promptlist[#promptlist]
		if choice == "draw" then
			if target:isKongcheng() and self:needKongcheng(target) then
			else
				sgs.updateIntention(player, target, -20)
			end
		elseif choice == "discard" then
			if target:getArmor() and self:needToThrowArmor(target) then
			elseif target:getHandcardNum() == 1 and self:needKongcheng(target) then
			elseif target:hasEquip() and self:hasSkills(sgs.lose_equip_skill, target) then
			else
				sgs.updateIntention(player, target, 20)
			end
		end
	end
end
--[[****************************************************************
	编号：^_^ - 002
	武将：静谧
	称号：无言的结局
	势力：蜀
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：静谧
	描述：回合结束时，你可以展示一张红心花色的手牌，令一名角色失去一点体力。
	状态：验证通过
]]--
--room:askForUseCard(player, "@@ConJingMi", "@ConJingMi")
sgs.ai_skill_use["@@ConJingMi"] = function(self, prompt, method)
	local hearts = {}
	local handcards = self.player:getHandcards()
	for _,card in sgs.qlist(handcards) do
		if card:getSuit() == sgs.Card_Heart then
			table.insert(hearts, card)
		end
	end
	if #hearts == 0 then
		return "."
	end
	local maxHp = -999
	local alives = self.room:getAlivePlayers()
	local victims = {}
	for _,p in sgs.qlist(alives) do
		local hp = p:getHp()
		if hp > maxHp then
			maxHp = hp
		end
		table.insert(victims, p)
	end
	local function getJingMiValue(target)
		local value = 2
		local hp = target:getHp()
		if hp <= 1 then
			value = value + 5
		end
		if self:hasSkills(sgs.masochism_skill, target) then
			value = value + 3
		end
		if getBestHp(target) > hp then
			value = value - 1
		end
		if self:needToLoseHp(target) then
			value = value - 1.5
		end
		if target:isLord() then
			value = value + 1
		end
		value = value + ( maxHp - hp ) * 0.3
		if self:isFriend(target) then
			value = - value
		elseif not self:isEnemy(target) then
			value = value * 0.5
		end
		return value
	end
	local values = {}
	for _,p in ipairs(victims) do
		values[p:objectName()] = getJingMiValue(p) 
	end
	local compare_func = function(a, b)
		local valueA = values[a:objectName()] or 0
		local valueB = values[b:objectName()] or 0
		if valueA == valueB then
			return a:getHp() < b:getHp()
		else
			return valueA > valueB
		end
	end
	table.sort(victims, compare_func)
	local target = victims[1]
	local value = values[target:objectName()] or 0
	if value <= 0 then
		return "."
	end
	self:sortByKeepValue(hearts)
	local heart = hearts[1]
	local card_str = "#ConJingMiCard:"..heart:getEffectiveId()..":->"..target:objectName()
	return card_str
end
--相关信息
sgs.ai_card_intention["ConJingMiCard"] = 50
sgs.ConJingMi_suit_value = {
	heart = 5,
}
sgs.ai_cardneed["ConJingMi"] = function(target, card, self)
	return card:getSuit() == sgs.Card_Heart
end
--[[****************************************************************
	编号：^_^ - 003
	武将：恬淡
	称号：生命中的舍弃
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：恬淡
	描述：当你成为一张卡牌的目标时，你可以弃置一名角色的一张牌。 
	状态：验证通过
]]--
--room:askForPlayerChosen(player, targets, "ConTianDan", "@ConTianDan", true, true)
sgs.ai_skill_playerchosen["ConTianDan"] = function(self, targets)
	return self:findPlayerToDiscard("he", true, true)
end
--room:askForCardChosen(player, target, "he", "ConTianDan")
--相关信息
sgs.ai_choicemade_filter["cardChosen"].ConTianDan = sgs.ai_choicemade_filter["cardChosen"].snatch
--[[****************************************************************
	编号：^_^ - 004
	武将：自然
	称号：积累的成果
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：自然（阶段技）
	描述：你可以获得一名角色区域中的一张牌。 
	状态：验证通过
]]--
--room:askForCardChosen(source, target, "hej", "ConZiRan")
--ConZiRanCard:Play
local ziran_skill = {
	name = "ConZiRan",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#ConZiRanCard") then
			return nil
		end
		return sgs.Card_Parse("#ConZiRanCard:.:")
	end,
}
table.insert(sgs.ai_skills, ziran_skill)
sgs.ai_skill_use_func["#ConZiRanCard"] = function(card, use, self)
	local target = self:findPlayerToDiscard("hej", true, false)
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["ConZiRanCard"] = sgs.ai_use_value["Snatch"]
sgs.ai_use_priority["ConZiRanCard"] = sgs.ai_use_priority["Snatch"]
sgs.ai_choicemade_filter["cardChosen"].ConZiRan = sgs.ai_choicemade_filter["cardChosen"].snatch
--[[****************************************************************
	编号：^_^ - 005
	武将：空灵
	称号：倾听烦恼
	势力：群
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：空灵（阶段技）
	描述：你可以展示一名角色的所有手牌，选择其中一张弃置之。
	状态：验证通过
]]--
--room:askForAG(source, handcard_ids, true, "ConKongLing")
--ConKongLingCard:Play
local kongling_skill = {
	name = "ConKongLing",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#ConKongLingCard") then
			return nil
		end
		return sgs.Card_Parse("#ConKongLingCard:.:")
	end,
}
table.insert(sgs.ai_skills, kongling_skill)
sgs.ai_skill_use_func["#ConKongLingCard"] = function(card, use, self)
	local target = self:findPlayerToDiscard("h", true, true)
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_card_intention["ConKongLingCard"] = function(self, card, from, tos)
	for _,to in ipairs(tos) do
		if to:getHandcardNum() == 1 and self:needKongcheng(to) then
		else
			sgs.updateIntention(from, to, 40)
		end
	end
end
--[[****************************************************************
	编号：^_^ - 006
	武将：高洁
	称号：灵魂的安抚
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：高洁（阶段技）
	描述：你可以令一名角色回复一点体力。
	状态：验证通过
]]--
--ConGaoJieCard:Play
local gaojie_skill = {
	name = "ConGaoJie",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#ConGaoJieCard") then
			return nil
		end
		return sgs.Card_Parse("#ConGaoJieCard:.:")
	end,
}
table.insert(sgs.ai_skills, gaojie_skill)
sgs.ai_skill_use_func["#ConGaoJieCard"] = function(card, use, self)
	local needHelp, doNotNeedHelp = self:getWoundedFriend(false, true)
	if #needHelp > 0 then
		use.card = card
		if use.to then
			use.to:append(needHelp[1])
		end
		return 
	end
	if #doNotNeedHelp > 0 then
		for _,friend in ipairs(doNotNeedHelp) do
			if friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 then
			elseif friend:hasSkill("longhun") and not self:isWeak(friend) then
			else
				use.card = card
				if use.to then
					use.to:append(friend)
				end
				return 
			end
		end
	end
end
--相关信息
sgs.ai_use_value["ConGaoJieCard"] = sgs.ai_use_value["QingnangCard"]
sgs.ai_use_priority["ConGaoJieCard"] = 1
sgs.ai_card_intention["ConGaoJieCard"] = sgs.ai_card_intention["QingnangCard"]
--[[****************************************************************
	编号：^_^ - 007
	武将：幽深
	称号：长路漫漫
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：幽深（阶段技）
	描述：你可以弃一张黑桃花色的手牌，令一名角色翻面。
	状态：验证通过
]]--
--ConYouShenCard:Play
local youshen_skill = {
	name = "ConYouShen",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#ConYouShenCard") then
			return nil
		elseif self.player:isKongcheng() then
			return nil
		end
		return sgs.Card_Parse("#ConYouShenCard:.:")
	end,
}
table.insert(sgs.ai_skills, youshen_skill)
sgs.ai_skill_use_func["#ConYouShenCard"] = function(card, use, self)
	local spades = {}
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		if c:getSuit() == sgs.Card_Spade then
			table.insert(spades, c)
		end
	end
	if #spades == 0 then
		return 
	end
	local target = nil
	self:sort(self.friends, "defense")
	for _,friend in ipairs(self.friends) do
		if not self:toTurnOver(friend, 0, "ConYouShen") then
			target = friend
			break
		end
	end
	if not target then
		if #self.enemies > 0 then
			self:sort(self.enemies, "threat")
			for _,enemy in ipairs(self.enemies) do
				if self:toTurnOver(enemy, 0, "ConYouShen") then
					target = enemy
					break
				end
			end
		end
	end
	if target then
		self:sortByUseValue(spades, true)
		local spade = spades[1]
		local card_str = "#ConYouShenCard:"..spade:getEffectiveId()..":->"..target:objectName()
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["ConYouShenCard"] = 3.5
sgs.ai_use_priority["ConYouShenCard"] = 2.5
sgs.ai_card_intention["ConYouShenCard"] = function(self, card, from, tos)
	for _,to in ipairs(tos) do
		if self:toTurnOver(to, 0, "ConYouShen") then
			sgs.updateIntention(from, to, 80)
		else
			sgs.updateIntention(from, to, -80)
		end
	end
end
sgs.ConYouShen_suit_value = {
	spade = 6,
}
sgs.ai_cardneed["ConYouShen"] = function(target, card, self)
	return card:getSuit() == sgs.Card_Spade
end
--[[****************************************************************
	编号：^_^ - 008
	武将：祥和
	称号：悲喜人生
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：祥和（阶段技）
	描述：你可以摸一张牌，然后令一名角色弃一张牌。
	状态：验证通过
]]--
--room:askForPlayerChosen(source, victims, "ConXiangHe", "@ConXiangHe", true, false)
sgs.ai_skill_playerchosen["ConXiangHe"] = function(self, targets)
	return self:findPlayerToDiscard("he", true, true)
end
--room:askForDiscard(target, "ConXiangHe", 1, 1, false, true, prompt)
--ConXiangHeCard:Play
local xianghe_skill = {
	name = "ConXiangHe",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#ConXiangHeCard") then
			return nil
		end
		return sgs.Card_Parse("#ConXiangHeCard:.:")
	end,
}
table.insert(sgs.ai_skills, xianghe_skill)
sgs.ai_skill_use_func["#ConXiangHeCard"] = function(card, use, self)
	use.card = card
end
--相关信息
sgs.ai_use_value["ConXiangHeCard"] = 4
sgs.ai_use_priority["ConXiangHeCard"] = 7
sgs.ai_card_intention["ConXiangHeCard"] = function(self, card, from, tos)
	for _,to in ipairs(tos) do
		if to:getArmor() and self:needToThrowArmor() then
		elseif to:getHandcardNum() == 1 and self:needKongcheng(to) then
		elseif to:hasEquip() and self:hasSkills(sgs.lose_equip_skill, to) then
		else
			sgs.updateIntention(from, to, 70)
		end
	end
end