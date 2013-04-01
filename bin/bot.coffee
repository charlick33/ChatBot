class settings
	currentsong: {}
	users: {}
	djs: []
	mods: []
	host: []
	hasWarned: false
	currentwoots: 0
	currentmehs: 0
	currentcurates: 0
	roomUrlPath: null#for lock. 'dubstep-den' in 'http://plug.dj/harrylafranc'
	internalWaitlist: []
	userDisconnectLog: []
	voteLog: {}
	seshOn: false
	forceSkip: false
	seshMembers: []
	launchTime: null
	totalVotingData:
		woots:0
		mehs:0
		curates:0
	pupScriptUrl: ''
	afkTime: 60*60*1000#Time without activity to be considered afk. 12 minutes in milliseconds
	songIntervalMessages: [
	]
	songCount: 0

	startup: =>
		@launchTime = new Date()
		@roomUrlPath = @getRoomUrlPath()

	getRoomUrlPath: =>
		window.location.pathname.replace(/\//g,'')

	newSong: ->
		@totalVotingData.woots += @currentwoots
		@totalVotingData.mehs += @currentmehs
		@totalVotingData.curates += @currentcurates

		@setInternalWaitlist()

		@currentsong = API.getMedia()
		if @currentsong != null
			return @currentsong
		else
			return false

	userJoin: (u)=>
		userIds = Object.keys(@users)
		if u.id in userIds
			@users[u.id].inRoom(true)
		else
			@users[u.id] = new User(u)
			@voteLog[u.id] = {}

	setInternalWaitlist: =>
		boothWaitlist = API.getDJs().slice(1)#remove current dj
		lineWaitList = API.getWaitList()
		fullWaitList = boothWaitlist.concat(lineWaitList)
		@internalWaitlist = fullWaitList

	activity: (obj) ->
		if(obj.type == 'message')
			@users[obj.fromID].updateActivity()

	startAfkInterval: =>
		@afkInterval = setInterval(afkCheck,2000)

	intervalMessages: =>
		@songCount++
		for msg in @songIntervalMessages
			if ((@songCount+msg['offset']) % msg['interval']) == 0
				API.sendChat msg['msg']

	implode: =>
		for item,val of @
			if(typeof @[item] == 'object') 
				delete @[item]
		clearInterval(@afkInterval)

	lockBooth: (callback=null)->
		$.ajax({
		    url: "http://plug.dj/_/gateway/room.update_options",
		    type: 'POST',
		    data: JSON.stringify({
		        service: "room.update_options",
		        body: [@roomUrlPath,{"boothLocked":true,"waitListEnabled":true,"maxPlays":1,"maxDJs":5}]
		    }),
		    async: this.async,
		    dataType: 'json',
		    contentType: 'application/json'
		}).done ->
			if callback?
				callback()

	unlockBooth: (callback=null)->
		$.ajax({
		    url: "http://plug.dj/_/gateway/room.update_options",
		    type: 'POST',
		    data: JSON.stringify({
		        service: "room.update_options",
		        body: [@roomUrlPath,{"boothLocked":false,"waitListEnabled":true,"maxPlays":1,"maxDJs":5}]
		    }),
		    async: this.async,
		    dataType: 'json',
		    contentType: 'application/json'
		}).done ->
			if callback?
				callback()


data = new settings()

class User

	afkWarningCount: 0#0:hasnt been warned, 1: one warning etc.
	lastWarning: null
	protected: false #if true pup will refuse to kick
	isInRoom: true#by default online

	constructor: (@user)->
		@init()

	init: =>
		@lastActivity = new Date()

	updateActivity: =>
		@lastActivity = new Date()
		@afkWarningCount = 0
		@lastWarning = null

	getLastActivity: =>
		return @lastActivity

	getLastWarning: =>
		if @lastWarning == null
			return false
		else
			return @lastWarning

	getUser: =>
		return @user

	getWarningCount: =>
		return @afkWarningCount

	getIsDj: =>
		DJs = API.getDJs()
		for dj in DJs
			if @user.id == dj.id
				return true
		return false

	warn: =>
		@afkWarningCount++
		@lastWarning = new Date()

	notDj: =>
		@afkWarningCount = 0
		@lastWarning = null

	inRoom: (online)=>
		@isInRoom = online

	updateVote: (v)=>
		if @isInRoom
			data.voteLog[@user.id][data.currentsong.id] = v

class RoomHelper
	lookupUser: (username)->
		for id,u of data.users
			if u.getUser().username == username
				return u.getUser()
		return false

	userVoteRatio: (user)->
		songVotes = data.voteLog[user.id]
		votes = {
			'woot':0,
			'meh':0
		}
		for songId, vote of songVotes
			if vote == 1
				votes['woot']++
			else if vote == -1
				votes['meh']++
		votes['positiveRatio'] = (votes['woot'] / (votes['woot']+votes['meh'])).toFixed(2)
		votes

pupOnline = ->
	API.sendChat "Bot Online!"

populateUserData = ->
	users = API.getUsers()
	for u in users
		data.users[u.id] = new User(u)
		data.voteLog[u.id] = {}
	return

initEnvironment = ->
	document.getElementById("button-vote-positive").click()
	document.getElementById("button-sound").click()
	Playback.streamDisabled = true
	Playback.stop()

initialize = ->
  pupOnline()
  populateUserData()
  initEnvironment()
  initHooks()
  data.startup()
  data.newSong()
  data.startAfkInterval()

afkCheck = ->
  for id,user of data.users
    now = new Date()
    lastActivity = user.getLastActivity()
    timeSinceLastActivity = now.getTime() - lastActivity.getTime()
    if timeSinceLastActivity > data.afkTime #has been inactive longer than afk time limit
      if user.getIsDj()#if on stage
        secsLastActive = timeSinceLastActivity / 1000
        if user.getWarningCount() == 0
          user.warn()
          API.sendChat "@"+user.getUser().username+", Je ne t'ai pas vu écrire depuis 1heure, es tu AFK ? Tu seras sorti dans la scène dans 5 minutes si tu restes inactif dans le chat."
        else if user.getWarningCount() == 1
          lastWarned = user.getLastWarning()#last time user was warned
          timeSinceLastWarning = now.getTime() - lastWarned.getTime()
          twoMinutes = 5*60*1000
          if timeSinceLastWarning > twoMinutes
            user.warn()
        else if user.getWarningCount() == 2#Time to remove
          lastWarned = user.getLastWarning()#last time user was warned
          timeSinceLastWarning = now.getTime() - lastWarned.getTime()
          oneMinute = 1000
          if timeSinceLastWarning > oneMinute
            DJs = API.getDJs()
            if DJs.length > 0 and DJs[0].id != user.getUser().id
              API.sendChat "@"+user.getUser().username+", tu avais été prévenu, restes actif dans le chat la prochaine fois."
              API.moderateRemoveDJ id
              user.warn()
      else
        user.notDj()

msToStr = (msTime) ->
  msg = ''
  timeAway = {'days':0,'hours':0,'minutes':0,'seconds':0}
  ms = {'day':24*60*60*1000,'hour':60*60*1000,'minute':60*1000,'second':1000}

  #split into days hours minutes and seconds
  if msTime > ms['day']
    timeAway['days'] = Math.floor msTime / ms['day']
    msTime = msTime % ms['day']
  if msTime > ms['hour']
    timeAway['hours'] = Math.floor msTime / ms['hour']
    msTime = msTime % ms['hour']
  if msTime > ms['minute']
    timeAway['minutes'] = Math.floor msTime / ms['minute']
    msTime = msTime % ms['minute']
  if msTime > ms['second']
    timeAway['seconds'] = Math.floor msTime / ms['second']

  #add non zero times
  if timeAway['days'] != 0
    msg += timeAway['days'].toString() + 'd'
  if timeAway['hours'] != 0
    msg += timeAway['hours'].toString() + 'h'
  if timeAway['minutes'] != 0
    msg += timeAway['minutes'].toString() + 'm'
  if timeAway['seconds'] != 0
    msg += timeAway['seconds'].toString() + 's'

  if msg != ''
    return msg
  else
    return false
	
	
class Command
	
	# Abstract of chat command
	# 	Required Attributes:
	# 		@parseType: How the chat message should be evaluated
	# 			- Options:
	# 				- 'exact' = chat message should exactly match command string
	# 				- 'startsWith' = substring from start of chat message to length
	# 					of command string should equal command string
	# 				- 'contains' = chat message contains command string
	# 		@command: String or Array of Strings that, when matched in message
	# 			corresponding with commandType, triggers bot functionality
	# 		@rankPrivelege: What user types are allowed to use this function
	# 			- Options:
	# 				- 'host' = only can be called by host
	#				- 'cohost' = can be called by hosts & co-hosts
	# 				- 'manager' or 'mod' = can be called by host, co-hosts, and managers
	#				- 'bouncer' = can be called by host, co-hosts, managers, and bouncers
	#				- 'featured' = can be called by host, co-hosts, managers, bouncers, and featured djs
	# 				- 'user' = can be called by all
	# 				- {'pointMin':min} = can be called by hosts and mods.  Users
	# 					can call if the # of points they have > pointMin
	# 		@functionality: actions bot will perform if conditions are satisfied
	# 			for chat command

	constructor: (@msgData) ->
		@init()

	init: ->
		@parseType=null
		@command=null
		@rankPrivelege=null

	functionality: (data)->
		return

	hasPrivelege: ->
		user = data.users[@msgData.fromID].getUser()
		switch @rankPrivelege
			when 'host'    then return user.permission is 5
			when 'cohost'  then return user.permission >=4
			when 'mod'     then return user.permission >=3
			when 'manager' then return user.permission >=3
			when 'bouncer' then return user.permission >=2
			when 'featured' then return user.permission >=1
			else return true

	commandMatch: ->
		msg = @msgData.message
		if(typeof @command == 'string')
			if(@parseType == 'exact')
				if(msg == @command)
					return true
				else
					return false
			else if(@parseType == 'startsWith')
				if(msg.substr(0,@command.length) == @command)
					return true
				else
					return false
			else if(@parseType == 'contains')
				if(msg.indexOf(@command) != -1)
					return true
				else
					return false
		else if(typeof @command == 'object')
			for command in @command
				if(@parseType == 'exact')
					if(msg == command)
						return true
				else if(@parseType == 'startsWith')
					if(msg.substr(0,command.length) == command)
						return true
				else if(@parseType == 'contains')
					if(msg.indexOf(command) != -1)
						return true
			return false
			
	evalMsg: ->
		if(@commandMatch() && @hasPrivelege())
			@functionality()
			return true
		else
			return false

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
				API.sendChat "@"+user.username+", @"+@msgData.from+" t'as recompensé avec "+@getCookie()+". Enjoy."



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
		


class statusCommand extends Command
	init: ->
		@command='/status'
		@parseType='exact'
		@rankPrivelege='featured'

	functionality: ->
		lt = data.launchTime
		month = lt.getMonth()+1
		day = lt.getDate()
		hour = lt.getHours()
		meridian = if (hour % 12 == hour) then 'AM' else 'PM'
		min = lt.getMinutes()
		min = if (min < 10) then '0'+min else min

		t = data.totalVotingData
		t['songs'] = data.songCount

		launch = 'Depuis le ' + month + '/' + day + ' à ' + hour + ':' + min + ' ' + meridian + '. '
		totals = '' + t.songs + ' musiques ont été jouées, accumulant ' + t.woots + ' woots, ' + t.mehs + ' mehs, et ' + t.curates + ' favoris.'
		
		msg = launch + totals

		API.sendChat msg
		
		
class unhookCommand extends Command
	init: ->
		@command='/unhook events all'
		@parseType='exact'
		@rankPrivelege='manager'

	functionality: ->
		API.sendChat 'Unhooking all events...'
		undoHooks()
		


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
		
		
class lockCommand extends Command
	init: ->
		@command='/lock'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		data.lockBooth()


class unlockCommand extends Command
	init: ->
		@command='/unlock'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		data.unlockBooth()

class swapCommand extends Command
	init: ->
		@command='/swap'
		@parseType='startsWith'
		@rankPrivelege='bouncer'

	functionality: ->
		msg = @msgData.message
		swapRegex = new RegExp("^/swap @(.+) for @(.+)$")
		users = swapRegex.exec(msg).slice(1)
		r = new RoomHelper()
		if users.length == 2
			userRemove = r.lookupUser users[0]
			userAdd = r.lookupUser users[1]
			if userRemove == false or userAdd == false
				API.sendChat 'Erreur dans un des deux noms'
				return false
			else
				data.lockBooth(->
					API.moderateRemoveDJ userRemove.id
					setTimeout(->
						API.moderateAddDJ userAdd.id
						setTimeout(->
							data.unlockBooth()
						,1500)
					,1500)
				)
		else
			API.sendChat "Il faut 2 noms séparés"
			
			
class popCommand extends Command
	init: ->
		@command='/pop'
		@parseType='exact'
		@rankPrivelege='bouncer'

	functionality: ->
		djs = API.getDJs()
		popDj = djs[djs.length-1]
		API.moderateRemoveDJ(popDj.id)
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
				
class resetAfkCommand extends Command
	init: ->
		@command='/resetafk'
		@parseType='startsWith'
		@rankPrivelege='bouncer'

	functionality: ->
		if @msgData.message.length > 10
			name = @msgData.message.substring(11)#remove @
			for id,u of data.users
				if u.getUser().username == name
					u.updateActivity()
					API.sendChat '@' + u.getUser().username + '\'s a été réinitialisé.'
					return
			API.sendChat 'Not sure who ' + name + ' is'
			return
		else
			API.sendChat 'Yo Gimme a name r-tard'
			return


class disconnectLookupCommand extends Command
	init: ->
		@command='/dclookup'
		@parseType='startsWith'
		@rankPrivelege='bouncer'

	functionality: ->
		cmd = @msgData.message
		if cmd.length > 11#includes name
			givenName = cmd.slice(11)
			for id,u of data.users
				if u.getUser().username == givenName
					dcLookupId = id
					disconnectInstances = []
					for dcUser in data.userDisconnectLog
						if dcUser.id == dcLookupId
							disconnectInstances.push(dcUser)
					if disconnectInstances.length > 0
						resp = u.getUser().username + ' à été déconnecté ' + disconnectInstances.length.toString() + ' fois'
						if disconnectInstances.length == 1#lol plurals
							resp += '. '
						else
							resp += '. '
						recentDisconnect = disconnectInstances.pop()
						dcHour = recentDisconnect.time.getHours()
						dcMins = recentDisconnect.time.getMinutes()
						if dcMins < 10
							dcMins = '0' + dcMins.toString()
						dcMeridian = if (dcHour % 12 == dcHour) then 'AM' else 'PM'
						dcTimeStr = ''+dcHour+':'+dcMins+' '+dcMeridian
						dcSongsAgo = data.songCount - recentDisconnect.songCount
						resp += 'la plus récente était à ' + dcTimeStr + ' (il y a ' + dcSongsAgo + ' musiques). '

						if recentDisconnect.waitlistPosition != undefined
							resp += 'Il lui restait ' + recentDisconnect.waitlistPosition + ' musique'
							if recentDisconnect.waitlistPosition > 1#lol plural
								resp += 's'
							resp += " avant d'être sur la scène."
						else
							resp += "Il n'était pas dans la fil d'attente."
						API.sendChat resp
						return
					else
						API.sendChat "I haven't seen " + u.getUser().username + " disconnect."
						return
			API.sendChat "I don't see a user in the room named '"+givenName+"'."
			
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
		

class avgVoteRatioCommand extends Command
	init: ->
		@command='/avgvoteratio'
		@parseType='exact'
		@rankPrivelege='manager'

	functionality: ->
		roomRatios = []
		r = new RoomHelper()
		for uid, votes of data.voteLog
			user = data.users[uid].getUser()
			userRatio = r.userVoteRatio(user)
			roomRatios.push userRatio['positiveRatio']
		averageRatio = 0.0
		for ratio in roomRatios
			averageRatio+=ratio
		averageRatio = averageRatio / roomRatios.length
		msg = "Selon le ratio de " + roomRatios.length.toString() + " utilisateurs, la moyenne de la room est de " + averageRatio.toFixed(2).toString() + "."
		API.sendChat msg
		
		
		

cmds = [
	cookieCommand,
	newSongsCommand,
	whyWootCommand,
	themeCommand,
	rulesCommand,
	roomHelpCommand,
	sourceCommand,
	wootCommand,
	badQualityCommand,
	downloadCommand,
	afksCommand,
	allAfksCommand,
	statusCommand,
	unhookCommand,
	dieCommand,
	reloadCommand,
	lockCommand,
	unlockCommand,
	swapCommand,
	popCommand,
	pushCommand,
	overplayedCommand,
	uservoiceCommand,
	whyMehCommand,
	skipCommand,
	commandsCommand,
	resetAfkCommand,
	forceSkipCommand,
	disconnectLookupCommand,
	voteRatioCommand,
	avgVoteRatioCommand
]

chatCommandDispatcher = (chat)->
    chatUniversals(chat)
    for cmd in cmds
    	c = new cmd(chat)
    	if c.evalMsg()
    		break


updateVotes = (obj) ->
    data.currentwoots = obj.positive
    data.currentmehs = obj.negative
    data.currentcurates = obj.curates



handleVote = (obj) ->
    data.users[obj.user.id].updateVote(obj.vote)

handleUserLeave = (user)->
    disconnectStats = {
        id : user.id
        time : new Date()
        songCount : data.songCount
    }
    i=0
    for u in data.internalWaitlist
        if u.id == user.id
            disconnectStats['waitlistPosition'] = i-1#0th position -> 1 song away
            data.setInternalWaitlist()#reload waitlist now that someone left
            break
        else
            i++
    data.userDisconnectLog.push(disconnectStats)
    data.users[user.id].inRoom(false)

antispam = (chat)->
    #test if message contains plug.dj room link
    plugRoomLinkPatt = /(\bhttps?:\/\/(www.)?plug\.dj[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
    if(plugRoomLinkPatt.exec(chat.message))
        #plug spam detected
        sender = API.getUser chat.fromID
        if(!sender.ambassador and !sender.moderator and !sender.owner and !sender.superuser)
            if !data.users[chat.fromID].protected
            else

beggar = (chat)->
    msg = chat.message.toLowerCase()
    responses = [
        "Good idea @{beggar}!  Don't earn your fans or anything thats so yesterday"
        "Guys @{beggar} asked us to fan him!  Lets all totally do it! à² _à² "
        "srsly @{beggar}? à² _à² "
        "@{beggar}.  Earning his fans the good old fashioned way.  Hard work and elbow grease.  A true american."
    ]
    r = Math.floor Math.random()*responses.length
    if msg.indexOf('fan me') != -1 or msg.indexOf('fan for fan') != -1 or msg.indexOf('fan pls') != -1 or msg.indexOf('fan4fan') != -1 or msg.indexOf('add me to fan') != -1

chatUniversals = (chat)->
    data.activity(chat)
    antispam(chat)
    beggar(chat)

hook = (apiEvent,callback) ->
    API.addEventListener(apiEvent,callback)

unhook = (apiEvent,callback) ->
    API.removeEventListener(apiEvent,callback)

apiHooks = [
    {'event':API.ROOM_SCORE_UPDATE, 'callback':updateVotes},
    {'event':API.CURATE_UPDATE, 'callback':announceCurate},
    {'event':API.USER_JOIN, 'callback':handleUserJoin},
    {'event':API.DJ_ADVANCE, 'callback':handleNewSong},
    {'event':API.VOTE_UPDATE, 'callback':handleVote},
    {'event':API.CHAT, 'callback':chatCommandDispatcher},
    {'event':API.USER_LEAVE, 'callback':handleUserLeave}
]

initHooks = ->
	hook pair['event'], pair['callback'] for pair in apiHooks

undoHooks = ->
    unhook pair['event'], pair['callback'] for pair in apiHooks

initialize()