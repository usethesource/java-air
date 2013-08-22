module lang::java::m3::JavaM3

extend analysis::m3::Core;

data Modifiers
	= \private()
	| \public()
	| \protected()
	| \friendly()
	| \static()
	| \final()
	| \synchronized()
	| \transient()
	| \abstract()
	| \native()
	| \volatile()
	| \strictfp()
	| \deprecated()
	| \annotation(loc \anno)
  	;

anno rel[loc from, loc to] M3@typeInheritance;    // sub-typing relation between classes and interfaces
anno rel[loc from, loc to] M3@methodInvocation;   // methods calling each other (including constructors)
anno rel[loc from, loc to] M3@fieldAccess;        // code using data (like fields)
anno rel[loc from, loc to] M3@typeDependency;     // using a type literal in some code (types of variables, annotations)
