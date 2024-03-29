// Generated by CoffeeScript 1.6.2
var skipCommand, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

skipCommand = (function(_super) {
  __extends(skipCommand, _super);

  function skipCommand() {
    _ref = skipCommand.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  skipCommand.prototype.init = function() {
    this.command = '/skip';
    this.parseType = 'exact';
    return this.rankPrivelege = 'bouncer';
  };

  skipCommand.prototype.functionality = function() {
    return API.moderateForceSkip();
  };

  return skipCommand;

})(Command);
