class unlockCommand extends Command
	init: ->
		@command='/unlock'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		data.unlockBooth()
