module lang::java::style::SizeViolations


import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Message;
import String;
import List;
import IO;

import lang::java::jdt::m3::Core;		// Java specific modules
import lang::java::jdt::m3::AST;

import lang::java::style::Utils;

data Message = sizeViolation(str category, loc pos);

/*
ExecutableStatementCount	DONE
FileLength					DONE
LineLength					TBD
MethodLength				DONE
AnonInnerLength				TBD
ParameterNumber				DONE
OuterTypeNumber				TBD
MethodCount					DONE
*/

list[Message] sizeViolationsChecks(node ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods) {
	return
		  executableStatementCount(ast, model, allClasses, allMethods)
		+ fileLength(ast, model, allClasses, allMethods)
		+ methodLength(ast, model, allClasses, allMethods)
		+ parameterNumber(ast, model, allClasses, allMethods)
		;

}

list[Message] executableStatementCount(node ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods){
	msgs = [];
	void checkSize(Statement ast){
		if(size([s | /Statement s := ast]) > 30){
			msgs += sizeViolation("ExecutableStatementCount", ast@src);
		}
	}
	top-down-break visit(ast){
		case \initializer(Statement initializerBody): checkSize(initializerBody);
    	case \method(_, _, _, _, Statement impl): 	checkSize(impl);
    	case \constructor(_, _, _, Statement impl): checkSize(impl);
	}
	return msgs;
}

list[Message] fileLength(Declaration ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods){
	return (ast@src.end.line > 2000) ?  sizeViolation("FileLength", ast@src) : [];
}

list[Message] methodLength(Declaration ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods){
	msgs = [];
	void checkSize(Declaration ast){
		if(ast@src.end.line - ast@src.begin.line > 150){
			msgs += sizeViolation("MethodLength", ast@src);
		}
	}
	
	top-down-break visit(ast){
    	case m: \method(_, _, list[Declaration] parameters, _, _): checkSize(m);
    	case m: \constructor(_, _, list[Declaration] parameters, _): checkSize(m);
	}
	return msgs;
}

list[Message] parameterNumber(node ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods){
	msgs = [];
	
	for(m <- getAllMethods(ast)){
		if(size(m.parameters) > 7){
			msgs += sizeViolation("ParameterNumber", m@src);
		}
	}
	return msgs;
}

// TODO: this check should be refined er method category
list[Message] methodCount(node ast, M3 model, list[Declaration] allClasses, list[Declaration] allMethods){
    return size([m | /m:\method(_, _, _, _, Statement impl) := ast]) > 100 ? sizeViolation("MethodCount", ast@src) : [];
}
