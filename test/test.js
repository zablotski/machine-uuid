// Generated by CoffeeScript 1.8.0
(function() {
  module.exports['id'] = function(test) {
    var getid;
    getid = require("../index");
    return getid(function(id1) {
      return getid(function(id2) {
        if (!id1) {
          test.ok(false, "no id");
        }
        console.log("UUID: ", id1);
        test.equals(id1, id2, 'same');
        return test.done();
      });
    });
  };

}).call(this);

//# sourceMappingURL=test.js.map
