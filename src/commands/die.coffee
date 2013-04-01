class dieCommand extends Command
	init: ->
		@command='/die'
		@parseType='exact'
		@rankPrivelege='manager'

	functionality: ->
		API.sendChat "Que se passe t'il !?"
		undoHooks()
		API.sendChat 'On me débranche, aidez moi!'
		data.implode()
		API.sendChat '...Hors-ligne...'
