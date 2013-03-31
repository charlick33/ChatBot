// Generated by CoffeeScript 1.6.2
var disconnectLookupCommand, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

disconnectLookupCommand = (function(_super) {
  __extends(disconnectLookupCommand, _super);

  function disconnectLookupCommand() {
    _ref = disconnectLookupCommand.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  disconnectLookupCommand.prototype.init = function() {
    this.command = '/dclookup';
    this.parseType = 'startsWith';
    return this.rankPrivelege = 'mod';
  };

  disconnectLookupCommand.prototype.functionality = function() {
    var cmd, dcHour, dcLookupId, dcMeridian, dcMins, dcSongsAgo, dcTimeStr, dcUser, disconnectInstances, givenName, id, recentDisconnect, resp, u, _i, _len, _ref1, _ref2;

    cmd = this.msgData.message;
    if (cmd.length > 11) {
      givenName = cmd.slice(11);
      _ref1 = data.users;
      for (id in _ref1) {
        u = _ref1[id];
        if (u.getUser().username === givenName) {
          dcLookupId = id;
          disconnectInstances = [];
          _ref2 = data.userDisconnectLog;
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            dcUser = _ref2[_i];
            if (dcUser.id === dcLookupId) {
              disconnectInstances.push(dcUser);
            }
          }
          if (disconnectInstances.length > 0) {
            resp = u.getUser().username + ' has disconnected ' + disconnectInstances.length.toString() + ' time';
            if (disconnectInstances.length === 1) {
              resp += '. ';
            } else {
              resp += 's. ';
            }
            recentDisconnect = disconnectInstances.pop();
            dcHour = recentDisconnect.time.getHours();
            dcMins = recentDisconnect.time.getMinutes();
            if (dcMins < 10) {
              dcMins = '0' + dcMins.toString();
            }
            dcMeridian = dcHour % 12 === dcHour ? 'AM' : 'PM';
            dcTimeStr = '' + dcHour + ':' + dcMins + ' ' + dcMeridian;
            dcSongsAgo = data.songCount - recentDisconnect.songCount;
            resp += 'Their most recent disconnect was at ' + dcTimeStr + ' (' + dcSongsAgo + ' songs ago). ';
            if (recentDisconnect.waitlistPosition !== void 0) {
              resp += 'They were ' + recentDisconnect.waitlistPosition + ' song';
              if (recentDisconnect.waitlistPosition > 1) {
                resp += 's';
              }
              resp += ' away from the DJ booth.';
            } else {
              resp += 'They were not on the waitlist.';
            }
            API.sendChat(resp);
            return;
          } else {
            API.sendChat("I haven't seen " + u.getUser().username + " disconnect.");
            return;
          }
        }
      }
      return API.sendChat("I don't see a user in the room named '" + givenName + "'.");
    }
  };

  return disconnectLookupCommand;

})(Command);
