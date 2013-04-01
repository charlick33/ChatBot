class pushCommand extends Command
	init: ->
		@command='/add'
		@parseType='startsWith'
		@rankPrivelege='bouncer'

	functionality: ->
		msg = @msgData.message
		if msg.length>@command.length+2#'/add @'
			name = msg.substr(@command.length+2)
			r = new RoomHelper()
			user = r.lookupUser(name)
			if user != false
				API.moderateAddDJ user.id