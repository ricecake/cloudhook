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
	maximumAge: 10000,
	timeout: 10000
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
		console.log('Selected item #' + e.itemIndex + ' of section #' + e.sectionIndex);
		console.log('The item is titled "' + e.item.title + '"');
		console.log('Pebble Account Token: ' + Pebble.getAccountToken());
		console.log('Pebble Watch Token: ' + Pebble.getWatchToken());
		console.log('lat= ' + pos.coords.latitude + ' lon= ' + pos.coords.longitude);
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


