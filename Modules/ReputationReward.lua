local PA = _G.ProjectAzilroka
if PA.Classic then return end

local RR = PA:NewModule('ReputationReward', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
local AS
PA.RR = RR

local _G = _G
local floor = floor
local pairs = pairs
local select = select
local wipe = wipe

local GetFactionInfo = _G.GetFactionInfo
local GetFactionInfoByID = _G.GetFactionInfoByID
local GetNumFactions = _G.GetNumFactions
local GetNumQuestLogRewardFactions = _G.GetNumQuestLogRewardFactions
local GetQuestLogRewardFactionInfo = _G.GetQuestLogRewardFactionInfo
local UnitAura = _G.UnitAura
local REWARDS_SECTION_OFFSET = 5

RR.Title = PA.ACL['|cFF16C3F2Reputation|r|cFFFFFFFFRewards|r']
RR.Description = PA.ACL['Adds Reputation into Quest Log & Quest Frame.']
RR.Authors = 'Azilroka'

function RR:BuildFactionHeaders()
	RR.FactionHeaders = {}

	local numFactions, CollapsedHeaders, header = GetNumFactions(), {}

	local i = 1

	while i <= numFactions do
		local _, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, factionID = GetFactionInfo(i)

		if isHeader and isCollapsed then
			CollapsedHeaders[#CollapsedHeaders + 1] = i
			ExpandFactionHeader(i)
			numFactions = GetNumFactions()
		end

		if isHeader then
			header = factionID
		end

		if factionID and header then
			RR.FactionHeaders[factionID] = header
		end

		i = i + 1
	end

	if #CollapsedHeaders > 0 then
		for k = #CollapsedHeaders, 1, -1 do
			CollapseFactionHeader(CollapsedHeaders[k])
		end
	end
end

function RR:GetFactionHeader(factionID)
	return RR.FactionHeaders[factionID]
end

function RR:GetBonusReputation(amtBase, factionID)
	local mult = 1
	local rep = amtBase

	if factionID == 609 or factionID == 576 or factionID == 529 then
		rep = rep * 2
	elseif factionID == 59 then
		rep = rep * 4
	end

	for i = 1, 40 do
		local ID = select(11, UnitAura('player', i))
		if not ID then break end
		if RR.AuraInfo[ID] and ((RR.AuraInfo[ID].faction == factionID) or (RR.AuraInfo[ID].faction == 0)) then
			mult = mult + RR.AuraInfo[ID].bonus
		end
	end

	local hasBonusRepGain = select(15, GetFactionInfoByID(factionID))
	if hasBonusRepGain then
		mult = mult * 2
	end

	return (rep * mult) - rep
end

function RR:Show()
	local numRepFactions = GetNumQuestLogRewardFactions()

	if numRepFactions == 0 then
		return
	end

	local numQuestRewards, numQuestChoices, numQuestCurrencies = 0, 0, 0
	local money, xp, honor

	if ( QuestInfoFrame.questLog ) then
		local questID = select(8, GetQuestLogTitle(GetQuestLogSelection()))
		if C_QuestLog.ShouldShowQuestRewards(questID) then
			numQuestRewards = GetNumQuestLogRewards()
			numQuestChoices = GetNumQuestLogChoices()
			numQuestCurrencies = GetNumQuestLogRewardCurrencies()
			money = GetQuestLogRewardMoney();
			xp = GetQuestLogRewardXP();
			honor = GetQuestLogRewardHonor();
		end
	else
		numQuestRewards = GetNumQuestRewards()
		numQuestChoices = GetNumQuestChoices()
		numQuestCurrencies = GetNumRewardCurrencies()
		money = GetRewardMoney();
		xp = GetRewardXP();
		honor = GetRewardHonor();
	end

	local rewardsFrame = QuestInfoFrame.rewardsFrame

	local totalRewards = numQuestRewards + numQuestChoices + numQuestCurrencies
	local buttonHeight = rewardsFrame.RewardButtons[1]:GetHeight()

	--if rewardsFrame.SkillPointFrame:IsShown() then
	--	lastFrame = rewardsFrame.SkillPointFrame
	--end

	local baseIndex = totalRewards or 0
	local buttonIndex = numQuestChoices == 1 and 1 or numQuestRewards > 0 and numQuestRewards or numQuestCurrencies > 0 and numQuestCurrencies or 0

	wipe(RR.ReputationInfo)

	for i = 1, numRepFactions do
		local factionID, amtBase = GetQuestLogRewardFactionInfo(i)
		local factionName, factionDescription, standingID, barMin, barMax, _, AtWar, ToggleAtWar, isHeader = GetFactionInfoByID(factionID)

		if factionName and (AtWar and ToggleAtWar or (not AtWar)) and (not (barMin == barMax)) then
			amtBase = floor(amtBase / 100)

			if PA.MyRace == 'Human' then
				amtBase = amtBase * 1.1
			end

			local amtBonus = RR:GetBonusReputation(amtBase, factionID)

			RR.ReputationInfo[factionID] = { Name = factionName, Description = factionDescription, Base = amtBase, Bonus = amtBonus, Header = isHeader, FactionID = factionID, Child = RR:GetFactionHeader(factionID), Standing = standingID }
		end
	end

	if RR.db.ShowAll then
		for _, Info in pairs(RR.ReputationInfo) do
			if Info.isHeader then
				RR.ReputationInfo[Info.FactionID] = nil
			end
		end
	else
		for _, Info in pairs(RR.ReputationInfo) do
			if (Info.FactionID ~= RR:GetFactionHeader(Info.Child)) and (Info.Child == RR:GetFactionHeader(Info.FactionID)) and (Info.Base == (RR.ReputationInfo[Info.Child] and RR.ReputationInfo[Info.Child].Base or 0)) then
				RR.ReputationInfo[Info.FactionID] = nil
			end
		end
	end

	local lastFrame = rewardsFrame.ItemReceiveText

	if ( QuestInfoFrame.mapView ) then
		if xp and xp > 0 then
			lastFrame = rewardsFrame.XPFrame
		end
		if money and money > 0 and xp and xp == 0 then
			lastFrame = rewardsFrame.MoneyFrame
		end
		if money and money > 0 and xp and xp > 0 then
			lastFrame = rewardsFrame.XPFrame
		end
	else
		if xp and xp > 0 then
			lastFrame = rewardsFrame.XPFrame
		end
	end

	local index
	local i = 1
	local Height = QuestInfoFrame.rewardsFrame:GetHeight()

	if not QuestInfoFrame.rewardsFrame:IsShown() then
		QuestInfoFrame.rewardsFrame:Show()
	end

	for _, Info in pairs(RR.ReputationInfo) do
		buttonIndex = buttonIndex + 1
		index = i + baseIndex

		local questItem = QuestInfo_GetRewardButton(rewardsFrame, index)
		if questItem then
			questItem:Show()

			questItem.type = "reward"
			questItem.objectType = "reputation"

			questItem.Name:SetText(Info.Name)
			SetItemButtonCount(questItem, Info.Base + Info.Bonus)
			SetItemButtonTexture(questItem, PA.MyFaction and (PA.MyFaction == 'Neutral' and 'Interface/Icons/Achievement_Character_Pandaren_Female' or ('Interface/Icons/PVPCurrency-Conquest-%s'):format(PA.MyFaction)))
			questItem.IconBorder:Hide()

			if Info.Base < 0 then
				questItem.Count:SetTextColor(1, 0, 0)
			elseif Info.Bonus > 0 then
				questItem.Count:SetTextColor(0, 1, 0)
			else
				questItem.Count:SetTextColor(1, 1, 1)
			end

			if (buttonIndex > 1) then
				if ( mod(buttonIndex, 2) == 1 ) then
					questItem:SetPoint('TOPLEFT', QuestInfo_GetRewardButton(rewardsFrame, index - 2) or lastFrame, 'BOTTOMLEFT', 0, -REWARDS_SECTION_OFFSET)
					Height = Height + buttonHeight + REWARDS_SECTION_OFFSET
					lastFrame = questItem
				else
					questItem:SetPoint('TOPLEFT', QuestInfo_GetRewardButton(rewardsFrame, index - 1) or lastFrame, 'TOPRIGHT', 2, 0)
				end
			else
				questItem:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_SECTION_OFFSET)
				Height = Height + buttonHeight + REWARDS_SECTION_OFFSET
				lastFrame = questItem
			end
			i = i + 1
		end
	end

	if ( numQuestChoices == 1 ) then
		local a, b, c, d, e = QuestInfoFrame.rewardsFrame.ItemReceiveText:GetPoint()
		QuestInfoFrame.rewardsFrame.ItemReceiveText:SetPoint(a, b, c, d, e - (((i % 2) == 1 and ((i / 2) * (buttonHeight + REWARDS_SECTION_OFFSET)) or 0)))
	end

	QuestInfoFrame.rewardsFrame:Show()
	QuestInfoFrame.rewardsFrame:SetHeight(Height)
end

function RR:GetOptions()
	local Options = {
		type = 'group',
		name = RR.Title,
		desc = RR.Description,
		get = function(info) return RR.db[info[#info]] end,
		set = function(info, value) RR.db[info[#info]] = value end,
		args = {
			Header = {
				order = 1,
				type = 'header',
				name = PA:Color(RR.Title),
			},
			ShowAll = {
				order = 2,
				type = 'toggle',
				name = 'Show All Reputation',
			},
			AuthorHeader = {
				order = 2,
				type = 'header',
				name = PA.ACL['Authors:'],
			},
			Authors = {
				order = 3,
				type = 'description',
				name = RR.Authors,
				fontSize = 'large',
			},
		},
	}

	PA.Options.args.ReputationReward = Options
end

function RR:BuildProfile()
	PA.Defaults.profile['ReputationReward'] = { ['Enable'] = true }

	PA.Options.args.general.args.ReputationReward = {
		type = 'toggle',
		name = RR.Title,
		desc = RR.Description,
	}
end

function RR:Initialize()
	RR.db = PA.db.ReputationReward

	if RR.db.Enable ~= true then
		return
	end

	if PA.AddOnSkins then
		AS = unpack(AddOnSkins)
	end

	RR:GetOptions()

	RR.ReputationInfo = {}

	-- ID = { bonus = .%, faction = factionID or 0 }
	RR.AuraInfo = {
		[61849] = { bonus = .1, faction = 0 },		--
		[24705] = { bonus = .1, faction = 0 },		--
		[95987] = { bonus = .1, faction = 0 },		--
		[39913] = { bonus = .1, faction = 947 },	-- Thrallmar
		[39911] = { bonus = .1, faction = 946 },	-- Honor Hold
		[39953] = { bonus = .1, faction = 1031 },	-- Sha'tar
		[46668] = { bonus = .1, faction = 0 },		-- Darkmoon Faire
		[136583] = { bonus = .1 , faction = 0 },	-- Darkmoon Faire

	--	["Banner of Cooperation"] = { bonus = .05, faction = 0 },
	--	["Standard of Unity"] = { bonus = .1, faction = 0 },
	--	["Battle Standard of Coordination"] = { bonus = .15, faction = 0 },
	}

	RR:BuildFactionHeaders()

--[[
	QUEST_TEMPLATE_DETAIL.elements = {
			QuestInfo_ShowTitle, 10, -10,
			QuestInfo_ShowDescriptionText, 0, -5,
			QuestInfo_ShowSeal, 0, 0,
			QuestInfo_ShowObjectivesHeader, 0, -15,
			QuestInfo_ShowObjectivesText, 0, -5,
			QuestInfo_ShowSpecialObjectives, 0, -10,
			QuestInfo_ShowGroupSize, 0, -10,
			QuestInfo_ShowRewards, 0, -15,
			RR.Show, 0, -15,
			QuestInfo_ShowSpacer, 0, -15,
		}

	QUEST_TEMPLATE_LOG.elements = {
			QuestInfo_ShowTitle, 5, -5,
			QuestInfo_ShowType, 0, -5,
			QuestInfo_ShowObjectivesText, 0, -5,
			QuestInfo_ShowTimer, 0, -10,
			QuestInfo_ShowObjectives, 0, -10,
			QuestInfo_ShowSpecialObjectives, 0, -10,
			QuestInfo_ShowRequiredMoney, 0, 0,
			QuestInfo_ShowGroupSize, 0, -10,
			QuestInfo_ShowDescriptionHeader, 0, -10,
			QuestInfo_ShowDescriptionText, 0, -5,
			QuestInfo_ShowSeal, 0, 0,
			QuestInfo_ShowRewards, 0, -10,
			RR.Show, 0, -15,
			QuestInfo_ShowSpacer, 0, -10
		}

	QUEST_TEMPLATE_REWARD.elements = {
			QuestInfo_ShowTitle, 5, -10,
			QuestInfo_ShowRewardText, 0, -5,
			QuestInfo_ShowRewards, 0, -10,
			RR.Show, 0, -15,
			QuestInfo_ShowSpacer, 0, -10
		}

	QUEST_TEMPLATE_MAP_REWARDS.elements = {
			QuestInfo_ShowRewards, 8, -42,
			RR.Show, 0, -15,
		}
]]
	RR:SecureHook('QuestInfo_Display', 'Show')
end
