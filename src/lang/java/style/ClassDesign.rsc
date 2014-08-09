module lang::java::style::ClassDesign

import analysis::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Message;
import String;
import List;

import lang::java::jdt::m3::Core;		// Java specific modules
import lang::java::jdt::m3::AST;

import lang::java::style::Utils;

import IO;

data Message = classDesign(str category, loc pos);

/*
VisibilityModifier			DONE
FinalClass					DONE
InterfaceIsType				TBD
HideUtilityClassConstructor	TBD
DesignForExtension			TBD
MutableException			DONE
ThrowsCount					DONE
InnerTypeLast				TBD
*/



list[Message] visibilityModifier(node ast, M3 model, OuterDeclarations decls){
	modifiers = model@modifiers;
	msgs = [];
	
	for(c <- classes(model)){
		for(f <- fields(model, c)){
			mods = modifiers[f];
			if(\public() in mods && !({\static(), \final()} < mods)){
				msgs += classDesign("VisibilityModifier", f);
			}
		}
	}
	
	return msgs;
}

list[Message] finalClass(node ast, M3 model, OuterDeclarations decls){
    modifiers = model@modifiers;
	msgs = [];
	bool isPrivate(loc m) = \private() in modifiers[m];
	
	bool hasOnlyPrivateConstructors(loc class){
		ncons = 0;
		for(m <-  methods(model, class)){
			if(m.scheme == "java+constructor"){
				ncons += 1;
				if(!isPrivate(m)){
					return false;
				}
			}	
		}
		return ncons > 0;
	}
	
	for(c <- classes(model)){
		if(hasOnlyPrivateConstructors(c) && \final() notin modifiers[c]){
			msgs += classDesign("FinalClass", c);
		}
	}

    return msgs;
}

list[Message] mutableException(node ast, M3 model, OuterDeclarations decls){
	modifiers = model@modifiers;
	msgs = [];
	bool hasOnlyFinalFields(loc c){
		return all(f <- fields(model, c), \final() in modifiers[f]);
	}
	
	for(c <- decls.allClasses){
		if((/Exception$/ := c.name || /Error$/ := c.name) && !hasOnlyFinalFields(c@decl /*getDeclaredEntity(c@src, model)*/)){ 
				msgs += classDesign("MutableException", c@src);
			}
	}

    return msgs;
}

list[Message] throwsCount(node ast, M3 model, OuterDeclarations decls){
	msgs = [];
	
	for(m <- decls.allMethods){
		if(m has impl && size([e | /e:\throw(_) := m.impl]) > 1){
			msgs += classDesign("ThrowsCount", m@src);
		}
	}

	return msgs;
}


