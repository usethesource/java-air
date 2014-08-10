@doc{this module is under construction}
@contributor{Jurgen Vinju}
@contributor{Paul Klint}
@contributor{Ashim Shahi}
@contributor{Bas Basten}
module lang::java::style::StyleChecker

import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Message;
import String;
import IO;
import lang::xml::DOM;
import Relation;
import Set;
import List;
import Node;

import lang::java::jdt::m3::Core;		// Java specific modules
import lang::java::jdt::m3::AST;

import lang::java::style::Utils;

import lang::java::style::BlockChecks;
import lang::java::style::ClassDesign;
import lang::java::style::Coding;
import lang::java::style::Imports;
import lang::java::style::Metrics;
import lang::java::style::Miscellaneous;
import lang::java::style::NamingConventions;
import lang::java::style::SizeViolations;

// Available checks

// TODO: It is better to have a list of check + applicable constructors and compute the other tables 

//// BlockChecks

// 		  emptyBlock
//		, needBraces
//		, avoidNestedBlocks

//// ClassDesignChecks
//
//		, visibilityModifier
//		, finalClass
//		, mutableException
//		, throwsCount
//
//// CodingChecks
//
//		, avoidInlineConditionals
//		, magicNumber
//		, missingSwitchDefault
//		, simplifyBooleanExpression
//		, simplifyBooleanReturn
//		, stringLiteralEquality
//		, nestedForDepth
//		, nestedIfDepth
//		, nestedTryDepth
//		, noClone
//		, noFinalizer
//		, returnCount
//		, defaultComesLast
//		, fallThrough
//		, multipleStringLiterals
//
//// ImportsChecks
//
//		, avoidStarImport
//		, avoidStaticImport
//		, illegalImport
//		, redundantImport
//
//// MetricsChecks
//
//		, booleanExpressionComplexity 
//		, classDataAbstractionCoupling
//		, classFanOutComplexity
//		, cyclomaticComplexity
//		, nPathComplexity
//
//// MiscellaneousChecks
//
//		, unCommentedMain
//		, outerTypeFilename
//
//// NamingComventions
//
//		, namingConventionsChecks
//
//// SizeViolationsChecks
//
//		, executableStatementCount
//		, fileLength
//		, methodLength
//		, parameterNumber




// Declaration Checking

// DeclarationChecker has as parameters:
// - decl, the current declaration to be processed
// - parents, the enclosing declrations
// - ast of the compilationUnit
// - M3 model
// and returns
// - a list of messages

alias DeclarationChecker = list[Message] (Declaration decl,  list[Declaration] parents, node ast, M3 model);

map[str, set[DeclarationChecker]] declarationCheckers = (
	"class4": 
		{visibilityModifier, finalClass, mutableException,outerTypeFilename},
	"interface4": 
		{outerTypeFilename},
	"enum4": 
		{outerTypeFilename},
	"method5": 
		{noClone, noFinalizer, unCommentedMain, outerTypeFilename, methodLength, parameterNumber},
	"method4": 
		{noClone, noFinalizer, unCommentedMain, outerTypeFilename, parameterNumber},
	"constructor4": 
		{},
	"initializer1":
		{},
	"import1":
		{avoidStarImport, avoidStaticImport, illegalImport}
);

// Run all checks associated with the constructor of the current declaration

list[Message] check(Declaration d, list[Declaration] parents,  node ast, M3 model){
	msgs = [];
	cons = getConstructor(d);
	if(!declarationCheckers[cons]?)
		return [];
	for(checker <- declarationCheckers[cons]){
		msgs += checker(d, parents, ast, model);
	}
	return msgs;
}

// Statement Checking

// StatementChecker has as parameters:
// - stat, the current statement to be processed
// - parents, the enclosing statements
// - ast of the compilationUnit
// - M3 model
// and returns
// - a list of messages

alias StatementChecker = list[Message] (Statement stat,  list[Statement] parents, node ast, M3 model);

map[str, set[StatementChecker]] statementCheckers = (
	"assert1": 
		{},
	"assert2": 
		{},
	"block1": 
		{avoidNestedBlocks},
	"break0": 
		{},
	"break1": 
		{},
	"continue0": 
		{},
	"continue1": 
		{},
	"do2": 
		{emptyBlock, needBraces},
	"empty0": 
		{},
	"foreach3": 
		{nestedForDepth},	
	"for3": 
		{emptyBlock, needBraces, nestedForDepth},	
	"for4": 
		{emptyBlock, needBraces, nestedForDepth},
	 "if2": 
	 	{emptyBlock, needBraces, nestedIfDepth},
	"if3": 
		{emptyBlock, needBraces, simplifyBooleanReturn, nestedIfDepth},   	
	"label2": 
		{} ,
	"return0": 
		{returnCount},
	"return1": 
		{returnCount},
	"switch2": 
		{missingSwitchDefault, defaultComesLast, fallThrough},
	"case1": 
		{},
	"defaultcase0": 
		{},
	"synchronizedStatement2": 
		{},
	"throw1": 
		{throwsCount},
	"try2": 
		{emptyBlock, nestedTryDepth},
	"try3": 
		{emptyBlock, nestedTryDepth},
	"catch2": 
		{},
	"declarationStatement1": 
		{},
	"while2": 
		{emptyBlock, needBraces},
	"expressionStatement1": 
		{},
	"constructorCall2": 
		{},
	"constructorCall3":	
		{}
);

// Run all checks associated with the constructor of the current statement

list[Message] check(Statement s, list[Statement] parents,  node ast, M3 model){
	msgs = [];
	cons = getConstructor(s);
	if(!statementCheckers[cons]?)
		return [];
	for(checker <- statementCheckers[cons]){
		msgs += checker(s, parents, ast, model);
	}
	return msgs;
}

// Expression Checking

// ExpressionChecker has as parameters:
// - exp, the current expression to be processed
// - parents, the enclosing expressions
// - ast of the compilationUnit
// - M3 model
// and returns
// - a list of messages

alias ExpressionChecker = list[Message] (Expression exp,  list[Expression] parents, node ast, M3 model);

map[str, set[ExpressionChecker]] expressionCheckers = (
	"conditional3":
		{avoidInlineConditionals},
	"number1":
		{magicNumber},
	"infix3":
		{simplifyBooleanExpression, stringLiteralEquality,booleanExpressionComplexity},
	"prefix2":
		{simplifyBooleanExpression,booleanExpressionComplexity},
	"stringLiteral1":
		{multipleStringLiterals},
	"newObject4":
		{classDataAbstractionCoupling},
	"newObject3":
		{classDataAbstractionCoupling},
	"newObject2":
		{classDataAbstractionCoupling}
);

// Run all checks associated with the constructor of the current expression

list[Message] check(Expression e, list[Expression] parents,  node ast, M3 model){
	msgs = [];
	cons = getConstructor(e);
	if(!expressionCheckers[cons]?)
		return [];
	for(checker <- expressionCheckers[cons]){
		msgs += checker(e, parents, ast, model);
	}
	return msgs;
}

list[Message] checkAll(node ast, M3 model){
	initCheckStates();
	registerCheckState("throwsCount", {"method5", "constructor4", "initializer1"}, 0, updateThrowsCount, finalizeThrowsCount);
	registerCheckState("returnCount", {"method5", "constructor4"}, 0, updateReturnCount, finalizeReturnCount);
	registerCheckState("classDataAbstractionCoupling", {"class4"}, {}, updateClassDataAbstractionCoupling, finalizeClassDataAbstractionCoupling);
	return  checkAll(ast, model, [], [], []);
}	


// The toplevel driver checkAll:
// - performs a top-down traversal of the compilationUnit
// - invokes the checks for the declrations/statements/expressions being encountered
// - accumaltes all messages and returns them

list[Message] checkAll(node ast, M3 model, list[Declaration] declParents, list[Statement] statParents, list[Expression] expParents){
	msgs = [];
	isDeclaration = false;

	switch(ast){
	
		case Declaration d:
			{ msgs += check(d, declParents, ast, model); 
				declParents = d + declParents; 
				enterDeclaration(d); 
				isDeclaration = true;
			}
		
		case Statement s: 
			{ msgs += check(s, statParents, ast, model); 
			  statParents = s + statParents; 
			}
		
		case Expression e:
			{ //println(e);
			  msgs += check(e, expParents, ast, model); 
			  expParents = e + expParents; 
			}
		
		case Type t:  /* ignore for the moment */;
		
		default:
			println("Other: <ast>");
	}
	
	for(child <- getChildren(ast)){
		switch(child){
		case list[Declaration] decls:
			for(d <- decls){
				msgs += checkAll(d, model, declParents, statParents, expParents);
			}
		case list[Statement] stats:
			for(s <- stats){
				msgs += checkAll(s, model, declParents, statParents, expParents);
			}
		case node nd:
			msgs += checkAll(nd, model, declParents, statParents, expParents);
			
		case list[node] nds:
			for(nd <- nds){
				msgs += checkAll(nd, model, declParents, statParents, expParents);
			}
		default:
			;//println("ignore child: <child> of <ast>");
		}
	}
	if(isDeclaration){
		msgs += leaveDeclaration(head(declParents));
	}
	return msgs;
}


  

@doc{For testing on the console; we should assume only a model for the current AST is in the model}
list[Message] styleChecker(M3 model, set[node] asts){
	msgs = [];
    for(ast <- asts){
		msgs += checkAll(ast, model);
    }
    return msgs;
 }
   
@doc{For integration into OSSMETER, we get the models and the ASTs per file}   
list[Message] styleChecker(map[loc, M3] models, map[loc, node] asts) 
  = [*checker(asts[f], models[f]) | f <- models, checker <- checkers];  
  

list[Message] main(loc dir = |project://java-checkstyle-tests|){
  m3model = createM3FromEclipseProject(dir);
  asts = createAstsFromDirectory(dir, true);
  return styleChecker(m3model, asts);
} 

// temporary functions for regression testing with checkstyle

@doc{measure if Rascal reports issues that CheckStyle also does}
test bool precision() {
  rascal = main();
  checkstyle = getCheckStyleMessages();
  
  println("comparing checkstyle:
          '  <size(checkstyle)> messages: <checkstyle>
          'with rascal:
          '  <size(rascal)> messages: <rascal>
          '");

  rascalPerFile = index({< path, mr> | mr <- rascal, /.*src\/<path:.*>$/ := mr.pos.path});
  checkstylePerFile = index({< path, mc> | mc:<l,_> <- checkstyle, /.*src\/<path:.*>$/ := l.path});
  
  missingFiles = rascalPerFile<0> - checkstylePerFile<0>;
  
  println("Rascal found errors in <size(rascalPerFile<0>)> files
          'Checkstyle found errors in <size(checkstylePerFile<0>)> files
          '<if (size(missingFiles) > 0) {>and these <size(missingFiles)> files are missing from checkstyle: 
          '  <missingFiles>
          '  counting for <(0 | it + size(rascalPerFile[m]) | m <- missingFiles)> missing messages.<} else {>and no files are missing.<}>
          '");
          
  rascalCategories = { mr.category | mr <- rascal};
  checkstyleCategories = { c | mc:<l,c> <- checkstyle};
  missingCategories = rascalCategories - checkstyleCategories;
  
  println("Rascal generated <size(rascalCategories)> different categories.
          'Checkstyle generated <size(checkstyleCategories)> different categories.
          '<if (size(missingCategories) > 0) {>and these <size(missingCategories)> are missing from checkstyle:
          '  <sort(missingCategories)>
          '  (compare to <sort(checkstyleCategories - rascalCategories)>)<}>
          '");   
  
  // filter for common files and report per file
  
  for (path <- rascalPerFile, path in checkstylePerFile, bprintln("analyzing file <path>")) {
       rascalPerCategory = index({<mr.category, <mr.pos.begin.line, mr.pos.end.line>> | mr <- rascalPerFile[path]});
       checkstylePerCategory = index({ <cat, mc.begin.line> | <mc,cat> <- checkstylePerFile[path]});
       missingCategories = rascalPerCategory<0> - checkstylePerCategory<0>;
       
       println("  Rascal found errors in <size(rascalPerCategory<0>)> categories.
               '  Checkstyle found errors in <size(checkstylePerCategory<0>)> categories.
               '  <if (size(missingCategories) > 0) {>and these <size(missingCategories)> categories are missing from checkstyle: 
               '  <missingCategories>
               '  counting for <(0 | it + size(rascalPerCategory[m]) | m <- missingCategories)> missing messages in <checkstylePerCategory><} else {>  and no categories are missing.<}>
               '");
       
       int matched = 0;
       int notmatched = 0;
               
       for (cat <- rascalPerCategory, cat in checkstylePerCategory, bprintln("  analyzing category <cat>")) {
         for (<sl, el> <- rascalPerCategory[cat], !any(l <- checkstylePerCategory[cat], l >= sl && l <= el)) {
            println("    line number not matched by checkstyle: <cat>, <path>, <rascalPerCategory[cat]>");
            notmatched += 1;
         }
         
         for (cat in checkstylePerCategory, <sl, el> <- rascalPerCategory[cat], l <- checkstylePerCategory[cat], l >= sl && l <= el) {
            println("    match found: <cat>, <path>, <l>");
            matched += 1;
         }
       }
       
       if (matched > 0 && notmatched > 0)  {
         println("  of the <matched + notmatched> messages, there were <matched> matches and <notmatched> missed messages in <path>
                 '");
       }        
  }
  
  return false;        
}

rel[loc, str] getCheckStyleMessages(loc checkStyleXmlOutput = |project://java-checkstyle-tests/lib/output.xml|) {
   txt = readFile(checkStyleXmlOutput);
   dom = parseXMLDOM(txt);
   str fix(str x) {
     return /^.*\.<y:[A-Za-z]*>Check$/ := x ? y : x;
   }
   r =  { <|file:///<fname>|(0,0,<toInt(l),0>,<toInt(l),0>), fix(ch)> 
        | /element(_, "file", cs:[*_,attribute(_,"name", fname),*_]) := dom
        , /e:element(_, "error", as) := cs
        , {*_,attribute(_, "source", ch), attribute(_,"line", l)} := {*as}
        };
   return r;
}


