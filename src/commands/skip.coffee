class skipCommand extends Command
	init: ->
		@command='/skip'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		API.moderateForceSkip()
		
