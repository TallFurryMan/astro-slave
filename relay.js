var five = require("johnny-five");
var board = new five.Board();

board.on("ready", function() {
	board.relays = new five.Relays([6, 18, 19, 20]);

	board.loop(5000, function() {
		board.relays.toggle();
	});
});
