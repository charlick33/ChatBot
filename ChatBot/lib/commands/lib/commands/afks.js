// Generated by CoffeeScript 1.6.2
var afksCommand, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

afksCommand = (function(_super) {
  __extends(afksCommand, _super);

  function afksCommand() {
    _ref = afksCommand.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  afksCommand.prototype.init = function() {
    this.command = '/afks';
    this.parseType = 'exact';
    return this.rankPrivelege = 'user';
  };

  afksCommand.prototype.functionality = function() {
    var dj, djAfk, djs, msg, now, _i, _len;

    msg = '';
    djs = API.getDJs();
    for (_i = 0, _len = djs.length; _i < _len; _i++) {
      dj = djs[_i];
      now = new Date();
      djAfk = now.getTime() - data.users[dj.id].getLastActivity().getTime();
      if (djAfk > (5 * 60 * 1000)) {
        if (msToStr(djAfk) !== false) {
          msg += dj.username + ' - ' + msToStr(djAfk);
          msg += '. ';
        }
      }
    }
    if (msg === '') {
      return API.sendChat("No one is AFK");
    } else {
      return API.sendChat('AFKs: ' + msg);
    }
  };

  return afksCommand;

})(Command);
