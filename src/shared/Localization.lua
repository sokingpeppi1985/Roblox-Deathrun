-- Minimal client-side text localization. Every entry is keyed by a short
-- language code; Localization.Get matches Player.LocaleId (e.g. "ru-ru",
-- "pt-br") by its language prefix and falls back to English for any
-- locale not listed here. Add a new language by adding a table below -
-- no other code needs to change.

local DEFAULT_LOCALE = "en"

local Localization = {}

Localization.Strings = {
	en = {
		GuideTitle = "Deathrun — How to Play",
		GuideBody = "Each round one player is picked as the Activator (red team) - everyone else is a Runner (blue team).\n\nRunners: reach the finish arch at the end of the course without dying to a trap. You earn coins for finishing, plus a bonus if you're first.\n\nActivator: you don't run the course, you control several manual traps along it. A button panel appears on your screen - press a button to trigger that trap for everyone at once. Each button has its own cooldown, so time it well. You earn coins for every Runner you take down, plus a bonus if your side wins the round.\n\nCoins are permanent and carry over between visits.",
		ActivatorTipTitle = "You are the Activator!",
		ActivatorTipBody = "Use the button panel on the left to trigger traps along the course. Each button has its own cooldown, so watch your timing.",
		CloseButton = "Got it",
		HelpButtonLabel = "?",

		StatusWaiting = "Waiting for players...",
		StatusIntermission = "New round in %d",
		StatusRoundActive = "Round in progress — %d sec",
		StatusPlayerFinished = "%s reached the finish!",
		StatusActivatorWin = "The Activator wins!",
		StatusRunnersWin = "The Runners win!",
		YouAreActivator = "You are the Activator! Use the trap panel.",

		CoinsLabel = "Coins: %d",
		CoinsAwardedFormat = "+%d coins — %s",
		ReasonFinish = "Finish",
		ReasonFirstPlace = "First place!",
		ReasonTeamWin = "Round win",
		ReasonKill = "Kill",

		TrapSwingLog = "Speed up the log (1.2)",
		TrapHiddenSpikes = "Grass spikes (2.2)",
		TrapSideSpikes = "Corridor spikes (3.2)",
		TrapRam = "Ram (4.3)",
		TrapFinalTrapdoor = "Final trapdoor (5.2)",
	},
	ru = {
		GuideTitle = "Deathrun — Как играть",
		GuideBody = "Каждый раунд один игрок становится Активатором (красная команда), остальные — Бегущими (синяя команда).\n\nБегущие: нужно добраться до финишной арки в конце трассы, не погибнув в ловушке. За финиш начисляются монеты, за первое место — дополнительный бонус.\n\nАктиватор: не бежит по трассе, а управляет ручными ловушками. На экране появляется панель кнопок — нажатие включает ловушку сразу у всех. У каждой кнопки своя перезарядка, так что выбирай момент. За каждого пойманного Бегущего начисляются монеты, плюс бонус, если твоя сторона победит в раунде.\n\nМонеты сохраняются между заходами в игру.",
		ActivatorTipTitle = "Ты — Активатор!",
		ActivatorTipBody = "Используй панель кнопок слева, чтобы включать ловушки на трассе. У каждой кнопки своя перезарядка — выбирай момент точнее.",
		CloseButton = "Понятно",
		HelpButtonLabel = "?",

		StatusWaiting = "Ожидание игроков...",
		StatusIntermission = "Новый раунд через %d",
		StatusRoundActive = "Раунд идёт — %d сек",
		StatusPlayerFinished = "%s добрался до финиша!",
		StatusActivatorWin = "Активатор победил!",
		StatusRunnersWin = "Бегущие победили!",
		YouAreActivator = "Вы — Активатор! Используйте панель ловушек.",

		CoinsLabel = "Монеты: %d",
		CoinsAwardedFormat = "+%d монет — %s",
		ReasonFinish = "Финиш",
		ReasonFirstPlace = "Первое место!",
		ReasonTeamWin = "Победа в раунде",
		ReasonKill = "Убийство",

		TrapSwingLog = "Ускорить бревно (1.2)",
		TrapHiddenSpikes = "Шипы в траве (2.2)",
		TrapSideSpikes = "Шипы в коридоре (3.2)",
		TrapRam = "Таран (4.3)",
		TrapFinalTrapdoor = "Финальный люк (5.2)",
	},
}

function Localization.Get(localeId)
	local prefix = localeId and localeId:match("^(%a+)")
	prefix = prefix and prefix:lower()
	return Localization.Strings[prefix] or Localization.Strings[DEFAULT_LOCALE]
end

return Localization
