class popCommand extends Command
	init: ->
		@command='/pop'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		djs = API.getDJs()
		popDj = djs[djs.length-1]
		API.moderateRemoveDJ(popDj.id)