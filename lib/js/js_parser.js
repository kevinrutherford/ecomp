var fs = require('fs'),
    esprima = require('esprima'),
    files = process.argv.slice(2);

// Executes visitor on the object and its children (recursively).
function traverse(object, visitor) {
    var key, child;

    visitor.call(null, object);
    for (key in object) {
        if (object.hasOwnProperty(key)) {
            child = object[key];
            if (typeof child === 'object' && child !== null) {
                traverse(child, visitor);
            }
        }
    }
}

function walk(filename) {
    var result = {
        num_branches: 0,
        num_superclasses: 0,
        num_dependencies: 0
    };
    content = fs.readFileSync(filename, 'utf-8');
    syntax = esprima.parse(content, { tolerant: true, loc: true, range: true });
	if (syntax) {
    traverse(syntax, function (node) {
        if (node.type === 'ConditionalExpression') {
            result.num_branches++;
        }
        if (node.type === 'IfStatement') {
            result.num_branches++;
        }
        if (node.type === 'SwitchStatement') {
            result.num_branches += (node.cases.length - 1);
        }
        if (node.type === 'ForStatement') {
            result.num_branches++;
        }
        if (node.type === 'ForInStatement') {
            result.num_branches++;
        }
        if (node.type === 'WhileStatement') {
            result.num_branches++;
        }
        if (node.type === 'DoWhileStatement') {
            result.num_branches++;
        }
        if (node.type === 'LogicalExpression' && (node.operator === '&&' || node.operator === '||')) {
            result.num_branches++;
        }
        if (node.type === 'CallExpression' && node.callee.name === 'require' && node.arguments.length == 1) { // node js style require
            result.num_dependencies++;
        }
        if (node.type === 'CallExpression' &&
            node.callee.object &&
            node.callee.object.name === 'require' &&
            node.callee.property &&
            node.callee.property.name === 'def' &&
            node.arguments.length == 3 &&
            node.arguments[1].type == 'ArrayExpression' // require.js v 0.15.0 style require, as used in TAL
            ) {
            result.num_dependencies += node.arguments[1].elements.length;
        }
        if (node.type === 'CallExpression' && node.callee.property && node.callee.property.name === 'extend') {
            result.num_superclasses++;
        }
    });
    return result;
}
	else console.log ("error found in file ", filename);
}

function walkAll(files) {
    var results = {};
    var errorCount = 0;
    for (var i = 0; i < files.length; i++) {
        try {
            var filename = files[i];
            results[filename] = walk(filename);
        }
        catch(err) {
            errorCount++;
        }
    }

    if (errorCount > 0 && files.length > 1) {
        console.error('WARNING: Error batch processing ' + errorCount + ' JavaScript files.');
    }

    return results;
}

console.log(JSON.stringify(walkAll(files)));
