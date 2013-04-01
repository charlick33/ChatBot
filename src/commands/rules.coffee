class rulesCommand extends Command
	init: ->
		@command='/rules'
		@parseType='startsWith'
		@rankPrivelege='featured'

	functionality: ->
		msg = "1) Tous les styles sont autorisés tant qu'ils plaisent. "
		msg += "2) Evitez les musiques déjà dans l'historique. 3) La limite de durée est de 6 minutes. "
		msg += "4) Restez actif dans le chat pour ne pas être sorti de la scène!"
		API.sendChat(msg)
		
