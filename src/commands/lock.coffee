class lockCommand extends Command
	init: ->
		@command='/lock'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		data.lockBooth()
