// Generated by CoffeeScript 1.6.2
var lockCommand, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

lockCommand = (function(_super) {
  __extends(lockCommand, _super);

  function lockCommand() {
    _ref = lockCommand.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  lockCommand.prototype.init = function() {
    this.command = '/lock';
    this.parseType = 'exact';
    return this.rankPrivelege = 'bouncer';
  };

  lockCommand.prototype.functionality = function() {
    return data.lockBooth();
  };

  return lockCommand;

})(Command);
