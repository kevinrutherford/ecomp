var fs = require('fs'),
    esprima = require('esprima'),
    path = process.argv[2];

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
        if (node.type === 'CallExpression' && node.callee.name === 'require') {
            result.num_dependencies++;
        }
    });
    console.log(result);
}

walk(path);
