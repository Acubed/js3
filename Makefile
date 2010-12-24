YUI_JAR = ../yui.jar
# alternatively, set JAVA=true or some other successful command (not false) to disable
JAVA = java

all: js3.js js3.node.js js3.min.js

js3.js: source/curiemap.js source/propertymap.js source/core.js
	cat source/curiemap.js source/propertymap.js source/core.js > js3.js
js3.node.js: js3.js source/node.exports.js
	cat js3.js source/node.exports.js > js3.node.js
js3.min.js: js3.js
	$(JAVA) -jar $(YUI_JAR) js3.js > js3.min.js
