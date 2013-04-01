class reloadCommand extends Command
	init: ->
		@command='/reload'
		@parseType='exact'
		@rankPrivelege='manager'

	functionality: ->
		API.sendChat 'brb'
		undoHooks()
		pupSrc = data.pupScriptUrl
		data.implode()
		$.getScript(pupSrc)