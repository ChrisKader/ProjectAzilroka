local PA = _G.ProjectAzilroka
local MF = PA:NewModule('MovableFrames', 'AceEvent-3.0')
_G.MovableFrames = MF

MF.Title = '|cFF16C3F2Movable|r |cFFFFFFFFFrames|r'
MF.Desciption = 'Make Blizzard Frames Movable'
MF.Authors = 'Azilroka    Simpy'

local pairs, unpack, tinsert, sort = pairs, unpack, tinsert, sort
local _G = _G
local IsAddOnLoaded, C_Timer = IsAddOnLoaded, C_Timer

local Frames = {
	'AddonList',
	'AudioOptionsFrame',
	'BankFrame',
	'BonusRollFrame',
	'BonusRollLootWonFrame',
	'BonusRollMoneyWonFrame',
	'CharacterFrame',
	'DressUpFrame',
	'FriendsFrame',
	'FriendsFriendsFrame',
	'GameMenuFrame',
	'GhostFrame',
	'GossipFrame',
	'GuildInviteFrame',
	'GuildRegistrarFrame',
	'HelpFrame',
	'InterfaceOptionsFrame',
	'ItemTextFrame',
	'LFDRoleCheckPopup',
	'LFGDungeonReadyDialog',
	'LFGDungeonReadyStatus',
	'LootFrame',
	'MailFrame',
	'MerchantFrame',
	'OpenMailFrame',
	'PetitionFrame',
	'PetStableFrame',
	'PVEFrame',
	'PVPReadyDialog',
	'QuestFrame',
	'QuestLogPopupDetailFrame',
	'RaidBrowserFrame',
	'RaidInfoFrame',
	'RaidParentFrame',
	'ReadyCheckFrame',
	'ReportCheatingDialog',
	'RolePollPopup',
	'ScrollOfResurrectionSelectionFrame',
	'SpellBookFrame',
	'SplashFrame',
	'StackSplitFrame',
	'StaticPopup1',
	'StaticPopup2',
	'StaticPopup3',
	'StaticPopup4',
	'TabardFrame',
	'TaxiFrame',
	'TimeManagerFrame',
	'TradeFrame',
	'TutorialFrame',
	'VideoOptionsFrame',
	'WorldStateAlwaysUpFrame',
	'WorldStateScoreFrame',
}

local AddOnFrames = {
	['Blizzard_AchievementUI'] = { 'AchievementFrame' },
	['Blizzard_ArchaeologyUI'] = { 'ArchaeologyFrame' },
	['Blizzard_ArtifactUI'] = { 'ArtifactRelicForgeFrame' },
	['Blizzard_AuctionUI'] = { 'AuctionFrame' },
	['Blizzard_BarberShopUI'] = { 'BarberShopFrame' },
	['Blizzard_BindingUI'] = { 'KeyBindingFrame' },
	['Blizzard_BlackMarketUI'] = { 'BlackMarketFrame' },
	['Blizzard_Calendar'] = { 'CalendarCreateEventFrame', 'CalendarFrame', 'CalendarViewEventFrame', 'CalendarViewHolidayFrame' },
	['Blizzard_ChallengesUI'] = { 'ChallengesLeaderboardFrame', 'ChallengesKeystoneFrame' },
	['Blizzard_Collections'] = { 'CollectionsJournal' },
	['Blizzard_EncounterJournal'] = { 'EncounterJournal' },
	['Blizzard_GarrisonUI'] = { 'GarrisonLandingPage', 'GarrisonMissionFrame', 'GarrisonCapacitiveDisplayFrame', 'GarrisonBuildingFrame', 'GarrisonRecruiterFrame', 'GarrisonRecruitSelectFrame', 'GarrisonShipyardFrame' },
	['Blizzard_GMChatUI'] = { 'GMChatStatusFrame' },
	['Blizzard_GMSurveyUI'] = { 'GMSurveyFrame' },
	['Blizzard_GuildBankUI'] = { 'GuildBankFrame' },
	['Blizzard_GuildControlUI'] = { 'GuildControlUI' },
	['Blizzard_GuildUI'] = { 'GuildFrame', 'GuildLogFrame' },
	['Blizzard_InspectUI'] = { 'InspectFrame' },
	['Blizzard_ItemAlterationUI'] = { 'TransmogrifyFrame' },
	['Blizzard_ItemSocketingUI'] = { 'ItemSocketingFrame' },
	['Blizzard_ItemUpgradeUI'] = { 'ItemUpgradeFrame' },
	['Blizzard_LookingForGuildUI'] = { 'LookingForGuildFrame' },
	['Blizzard_MacroUI'] = { 'MacroFrame' },
	['Blizzard_OrderHallUI'] = { 'OrderHallTalentFrame' },
	['Blizzard_QuestChoice'] = { 'QuestChoiceFrame' },
	['Blizzard_TalentUI'] = { 'PlayerTalentFrame' },
	['Blizzard_TalkingHeadUI'] = { 'TalkingHeadFrame' },
	['Blizzard_TradeSkillUI'] = { 'TradeSkillFrame' },
	['Blizzard_TrainerUI'] = { 'ClassTrainerFrame' },
	['Blizzard_VoidStorageUI'] = { 'VoidStorageFrame' },
}

local function LoadPosition(self)
	if self.IsMoving == true then return end
	local Name = self:GetName()
	if MF.db[Name] and MF.db[Name]['Permanent'] and MF.db[Name]['Points'] then
		self:ClearAllPoints()
		self:SetPoint(unpack(MF.db[Name]['Points']))
	end
end

local function OnDragStart(self)
	self.IsMoving = true
	self:StartMoving()
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self.IsMoving = false
	local Name = self:GetName()
	if MF.db[Name] and MF.db[Name]['Permanent'] then
		local a, b, c, d, e = self:GetPoint()
		b = self:GetParent():GetName() or UIParent
		if Name == 'QuestFrame' or Name == 'GossipFrame' then
			MF.db['GossipFrame'].Points = {a, b, c, d, e}
			MF.db['QuestFrame'].Points = {a, b, c, d, e}
		else
			MF.db[Name].Points = {a, b, c, d, e}
		end
	else
		self:SetUserPlaced(false)
	end
end

function MF:MakeMovable(Frame)
	local Name = Frame:GetName()

	if not Name then return end

	if Name == 'AchievementFrame' then AchievementFrameHeader:EnableMouse(false) UIPanelWindows[Name] = {} end

	Frame:EnableMouse(true)
	Frame:SetMovable(true)
	Frame:RegisterForDrag('LeftButton')
	Frame:SetClampedToScreen(true)
	Frame:HookScript('OnShow', LoadPosition)
	Frame:HookScript('OnDragStart', OnDragStart)
	Frame:HookScript('OnDragStop', OnDragStop)
	Frame:HookScript('OnHide', OnDragStop)
	if Name == 'WorldStateAlwaysUpFrame' then
		Frame:HookScript('OnEnter', function(self) self:SetTemplate() end)
		Frame:HookScript('OnLeave', function(self) self:StripTextures() end)
	end

	C_Timer.After(0, function()
		if MF.db[Name] and MF.db[Name]['Permanent'] == true and MF.db[Name]['Points'] then
			Frame:ClearAllPoints()
			Frame:SetPoint(unpack(MF.db[Name]['Points']))
		end
	end)
end

function MF:ADDON_LOADED(_, addon)
	if AddOnFrames[addon] then
		for _, Frame in pairs(AddOnFrames[addon]) do
			self:MakeMovable(_G[Frame])
		end
	end
end

function MF:GetOptions()
	local Options = {
		order = 209,
		type = 'group',
		name = MF.Title,
		desc = MF.Desciption,
		args = {
			Header = {
				order = 0,
				type = 'header',
				name = PA:Color(MF.Title),
			},
			permanent = {
				order = 1,
				type = 'group',
				guiInline = true,
				name = PA.ACL['Permanent Moving'],
				args = {},
			},
			reset = {
				order = 2,
				type = 'group',
				guiInline = true,
				name = PA.ACL['Reset Moving'],
				args = {},
			},
			AuthorHeader = {
				order = 3,
				type = 'header',
				name = PA.ACL['Authors:'],
			},
			Authors = {
				order = 4,
				type = 'description',
				name = MF.Authors,
				fontSize = 'large',
			},
		},
	}

	sort(self.AllFrames)

	local Index = 1
	for _, Name in pairs(self.AllFrames) do
		Options.args.permanent.args[Name] = {
			order = Index,
			type = 'toggle',
			name = Name,
			get = function(info) return MF.db[info[#info]]['Permanent'] end,
			set = function(info, value) MF.db[info[#info]]['Permanent'] = value end,
		}

		Options.args.reset.args[Name] = {
			order = Index,
			type = 'execute',
			name = Name,
			disabled = function(info) return not MF.db[info[#info]]['Permanent'] end,
			func = function(info) HideUIPanel(_G[info[#info]]) end,
		}

		Index = Index + 1
	end

	self.AllFrames = nil

	PA.Options.args.MovableFrames = Options
end

function MF:BuildProfile()
	self.AllFrames = CopyTable(Frames)

	for _, Table in pairs(AddOnFrames) do
		for _, Frame in pairs(Table) do
			tinsert(self.AllFrames, Frame)
		end
	end

	local Defaults = { profile = {} }

	for _, Frame in pairs(self.AllFrames) do
		if not Defaults.profile[Frame] then
			Defaults.profile[Frame] = { ['Permanent'] = false }
		end
	end

	self.data = PA.ADB:New('MovableFramesDB', Defaults)
	self.data.RegisterCallback(self, 'OnProfileChanged', 'SetupProfile')
	self.data.RegisterCallback(self, 'OnProfileCopied', 'SetupProfile')
	self.db = self.data.profile
end

function MF:SetupProfile()
	self.db = self.data.profile
end

function MF:Initialize()
	if PA.Tukui then
		tinsert(Frames, 'LossOfControlFrame')
		sort(Frames)
	end

	self:BuildProfile()
	self:GetOptions()

	for i = 1, #Frames do
		local frame = _G[Frames[i]]
		if frame then
			self:MakeMovable(frame)
		else
			PA:Print(PA.ACL["Frame doesn't exist: "]..Frames[i])
		end
	end

	-- Check Forced Loaded AddOns
	for AddOn, Table in pairs(AddOnFrames) do
		if IsAddOnLoaded(AddOn) then
			for _, Frame in pairs(Table) do
				self:MakeMovable(_G[Frame])
			end
		end
	end

	hooksecurefunc(ExtendedUI['CAPTUREPOINT'], 'create', function(id)
		if _G['WorldStateCaptureBar'..id].MoverAssigned then return end
		MF:MakeMovable(_G['WorldStateCaptureBar'..id])
		_G['WorldStateCaptureBar'..id].MoverAssigned = true
	end)

	self:RegisterEvent('ADDON_LOADED')
end
