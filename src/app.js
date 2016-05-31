/**
 * Welcome to Pebble.js!
 *
 * This is where you write your app.
 */

var UI   = require('ui');
var ajax = require('ajax');

// Choose options about the data returned
var options = {
	enableHighAccuracy: true,
	maximumAge: 30000,
	timeout: 15000
};

var main = new UI.Menu({
	sections: [{
		items: [{
			title: 'Context A',
		}, {
			title: 'Context B',
		}, {
			title: 'Context C',
		}, {
			title: 'Context D',
		}]
	}]
});

main.show();

main.on('select', function(e) {
	// Request current position
	navigator.geolocation.getCurrentPosition(function(pos) {
		ajax({
			url:    'https://cloudhook.tfm.nu/api/event',
			type:   'json',
			method: 'post',
			data: {
				account: Pebble.getAccountToken(),
				source:  Pebble.getWatchToken(),
				type:    e.item.title,
				lat:     pos.coords.latitude,
				lon:     pos.coords.longitude,
				time:    Date.now()
			}
		}, function(data) {
				console.log('Sent Event and got response');
		});
	}, error, options);
});


function error(err) {
  console.log('location error (' + err.code + '): ' + err.message);
}


