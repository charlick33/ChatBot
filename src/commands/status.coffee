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