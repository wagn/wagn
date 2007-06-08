/**
 * Parse source and update TestCase. Throw an exception if any error occurs.
 *
 * @param testCase TestCase to update
 * @param source The source to parse
 */
function parse(testCase, source) {
	var doc = source;
	var commands = [];
	testCase.header = '';
	testCase.footer = '';
	while (doc.length > 0) {
		var line = /(.*)(\r\n|[\r\n])?/.exec(doc);
		if (line[1] && line[1].match(/^\|/)) {
			var array = line[1].split(/\|/);
			if (array.length >= 3) {
				var command = new Command();
				command.command = array[1];
				command.target = array[2];
				if (array.length > 3) command.value = array[3];
				commands.push(command);
			}
			testCase.footer = '';
		} else if (commands.length == 0) {
			testCase.header += line[0];
		} else {
			testCase.footer += line[0];
		}
		doc = doc.substr(line[0].length);
	}
	testCase.setCommands(commands);
}1

/**
 * Format TestCase and return the source.
 *
 * @param testCase TestCase to format
 * @param name The name of the test case, if any. It may be used to embed title into the source.
 */
function format(testCase, name) {
	var result = testCase.header || '';
	result += formatCommands(testCase.commands);
	if (testCase.footer) result += testCase.footer;
	return result;
}

/**
 * Format an array of commands to the snippet of source.
 * Used to copy the source into the clipboard.
 *
 * @param The array of commands to sort.
 */
function formatCommands(commands) {
	var result = '';
	for (var i = 0; i < commands.length; i++) {
		var command = commands[i];
		if (command.type == 'command') {
			result += '|' + command.command + '|' + command.target + '|' + command.value + "|\n";
		}
	}
	return result;
}

/*
 * Optional: The customizable option that can be used in format/parse functions.
 */
//options = {nameOfTheOption: 'The Default Value'}

/*
 * Optional: XUL XML String for the UI of the options dialog
 */
//configForm = '<textbox id="options_nameOfTheOption"/>'
