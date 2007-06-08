/*
 * Selenium on Rails RSelenese format for Selenium IDE
 * 
 * Written by Shinya Kasatani (kasatani at gmail.com)
 */

load('formatCommandOnlyAdapter.js');

function string(value) {
	if (value != null) {
		value = value.replace(/\\/g, '\\\\');
		value = value.replace(/\"/g, '\\"');
		value = value.replace(/\r/g, '\\r');
		value = value.replace(/\n/g, '\\n');
		return '"' + value + '"';
	} else {
		return '""';
	}
}

function underscore(text) {
	return text.replace(/[A-Z]/g, function(str) {
			return '_' + str.toLowerCase();
		});
}

function formatCommand(command) {
	var line = underscore(command.command);
	if (command.target) {
		line += ' ' + string(command.target);
		if (command.value) {
			line += ', ' + string(command.value);
		}
	}
	return line;
}

this.playable = false;
