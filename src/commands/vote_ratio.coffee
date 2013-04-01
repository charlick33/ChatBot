class voteRatioCommand extends Command
	init: ->
		@command='/voteratio'
		@parseType='startsWith'
		@rankPrivelege='bouncer'

	functionality: ->
		r = new RoomHelper()
		msg = @msgData.message
		if msg.length > 12 #includes username
			name = msg.substr(12)
			u = r.lookupUser(name)
			if u != false
				votes = r.userVoteRatio(u)
				msg = u.username + " a woot "+votes['woot'].toString()+" fois"
				if votes['woot'] == 1
					msg+=', '
				else
					msg+=', '
				msg += "et meh "+votes['meh'].toString()+" fois"
				if votes['meh'] == 1
					msg+='. '
				else
					msg+='. '
				msg+="Son ratio de woot et de " + votes['positiveRatio'].toString() + "."
				API.sendChat msg
			else
				API.sendChat "I don't recognize a user named '"+name+"'"
		else
			API.sendChat "I'm not sure what you want from me..."
		
