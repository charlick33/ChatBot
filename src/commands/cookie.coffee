class cookieCommand extends Command
	init: ->
		@command='cookie'
		@parseType='startsWith'
		@rankPrivelege='featured'

	getCookie: ->
		cookies = [
			"un cookie au chocolat"
			"un cookie au sucre"
			"un cookie au raisin sec"
			"un brownie chocolat/noisette"
			"une poche d'haribo"
			"un scooby snack"
			"un muffin a la cerise"
			"une glace"
		]
		c = Math.floor Math.random()*cookies.length
		cookies[c]

	functionality: ->
		msg = @msgData.message
		r = new RoomHelper()
		if(msg.substring(7, 8) == "@") #Valid cookie argument including a username!
			user = r.lookupUser(msg.substr(8))
			if user == false
				API.sendChat "/em ne trouve pas '"+msg.substr(8)+"' dans la room et mange lui même le cookie"
				return false
			else
				API.sendChat "@"+user.username+", @"+@msgData.from+" t'as recompensé avec un "+@getCookie()+". Enjoy."
