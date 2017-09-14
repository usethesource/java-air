@doc{
.Synopsis
extends the M3 [$analysis/m3/Core] with Java specific concepts such as inheritance and overriding.

.Description

For a quick start, go find <<createM3FromEclipseProject>>.
}
module lang::java::m3::Core

extend lang::java::m3::TypeSymbol;
import lang::java::m3::Registry;
import lang::java::m3::AST;

extend analysis::m3::Core;

import analysis::graphs::Graph;
import analysis::m3::Registry;

import IO;
import ValueIO;
import String;
import Relation;
import Set;
import Map;
import Node;
import List;

import util::FileSystem;

data M3(
	rel[loc from, loc to] extends = {},            // classes extending classes and interfaces extending interfaces
	rel[loc from, loc to] implements = {},         // classes implementing interfaces
	rel[loc from, loc to] methodInvocation = {},   // methods calling each other (including constructors)
	rel[loc from, loc to] fieldAccess = {},        // code using data (like fields)
	rel[loc from, loc to] typeDependency = {},     // using a type literal in some code (types of variables, annotations)
	rel[loc from, loc to] methodOverrides = {},    // which method override which other methods
	rel[loc declaration, loc annotation] annotations = {}
);


data Language(str version="") = java();

public M3 composeJavaM3(loc id, set[M3] models) {
  m = composeM3(id, models);
  m.extends = {*model.extends | model <- models};
  m.implements = {*model.implements | model <- models};
  m.methodInvocation = {*model.methodInvocation | model <- models};
  m.fieldAccess = {*model.fieldAccess | model <- models};
  m.typeDependency = {*model.typeDependency | model <- models};
  m.methodOverrides = {*model.methodOverrides | model <- models};
  m.annotations = {*model.annotations | model <- models};
  return m;
}

public M3 link(M3 projectModel, set[M3] libraryModels) {
  projectModel.declarations = { <name[authority=projectModel.id.authority], src> | <name, src> <- projectModel.declarations };
  for (libraryModel <- libraryModels) {
    libraryModel.declarations = { <name[authority=libraryModel.id.authority], src> | <name, src> <- libraryModel.declarations }; 
  }
}

public M3 createM3FromFile(loc file, bool errorRecovery = false, list[loc] sourcePath = [], list[loc] classPath = [], str javaVersion = "1.7") {
    result = createM3sFromFiles({file}, errorRecovery = errorRecovery, sourcePath = sourcePath, classPath = classPath, javaVersion = javaVersion);
    if ({oneResult} := result) {
        return oneResult;
    }
    throw "Unexpected number of M3s returned for <file>";
}

@javaClass{org.rascalmpl.library.lang.java.m3.internal.EclipseJavaCompiler}
@reflect
public java set[M3] createM3sFromFiles(set[loc] files, bool errorRecovery = false, list[loc] sourcePath = [], list[loc] classPath = [], str javaVersion = "1.7");

public M3 createM3FromFiles(loc projectName, set[loc] files, bool errorRecovery = false, list[loc] sourcePath = [], list[loc] classPath = [], str javaVersion = "1.7")
    = composeJavaM3(projectName, createM3sFromFiles(files, errorRecovery = errorRecovery, sourcePath = sourcePath, classPath = classPath, javaVersion = javaVersion));

@javaClass{org.rascalmpl.library.lang.java.m3.internal.EclipseJavaCompiler}
@reflect
public java tuple[set[M3], set[Declaration]] createM3sAndAstsFromFiles(set[loc] files, bool errorRecovery = false, list[loc] sourcePath = [], list[loc] classPath = [], str javaVersion = "1.7");

@javaClass{org.rascalmpl.library.lang.java.m3.internal.EclipseJavaCompiler}
@reflect
public java M3 createM3FromString(loc fileName, str contents, bool errorRecovery = false, list[loc] sourcePath = [], list[loc] classPath = [], str javaVersion = "1.7");

@javaClass{org.rascalmpl.library.lang.java.m3.internal.EclipseJavaCompiler}
@reflect
public java M3 createM3FromJarClass(loc jarClass);

@javaClass{org.rascalmpl.library.lang.java.m3.internal.EclipseJavaCompiler}
@reflect
public java M3 createM3FromJarFile(loc jarLoc);

@doc{
.Synopsis
globs for jars, class files and java files in a directory and tries to compile all source files into an [$analysis/m3] model
}
public M3 createM3FromDirectory(loc project, bool errorRecovery = false, str javaVersion = "1.7") {
    if (!(isDirectory(project))) {
      throw "<project> is not a valid directory";
    }
    
    list[loc] classPaths = [];
    set[str] seen = {};
    for (j <- find(project, "jar"), isFile(j)) {
        hash = md5HashFile(j);
        if (!(hash in seen)) {
            classPaths += j;
            seen += hash;
        }
    }
    sourcePaths = getPaths(project, "java");
    M3 result = composeJavaM3(project, createM3sFromFiles({p | sp <- sourcePaths, p <- find(sp, "java"), isFile(p)}, errorRecovery = errorRecovery, sourcePath = [*findRoots(sourcePaths)], classPath = classPaths, javaVersion = javaVersion));
    registerProject(project, result);
    return result;
}


public M3 createM3FromJar(loc jarFile) {
	loc jarLoc = jarFile;
	
	if(!startsWith(jarLoc.scheme, "jar")) {
		jarLoc.scheme = "jar+<jarLoc.scheme>";
		jarLoc.path = "<jarLoc.path>!";
	}
	else {
		jarLoc.path = if(!endsWith(jarLoc.path,"!")) "<jarLoc.path>!"; else jarLoc.path;
	}
	
	if(!isDirectory(jarLoc)) {
		throw "The provided file is not a vali Jar URI.";
	}
	
    M3 model = createM3FromJarFile(jarLoc);
    rel[loc,loc] dependsOn = model.extends + model.implements;
    model.typeDependency = model.typeDependency + dependsOn;

	return model;
}

private str classPathToStr(loc jarClass) {
    return substring(jarClass.path,findLast(jarClass.path,"!")+1,findLast(jarClass.path,"."));
}

public bool isCompilationUnit(loc entity) = entity.scheme == "java+compilationUnit";
public bool isPackage(loc entity) = entity.scheme == "java+package";
public bool isClass(loc entity) = entity.scheme == "java+class";
public bool isConstructor(loc entity) = entity.scheme == "java+constructor";
public bool isMethod(loc entity) = entity.scheme == "java+method" || entity.scheme == "java+constructor";
public bool isParameter(loc entity) = entity.scheme == "java+parameter";
public bool isVariable(loc entity) = entity.scheme == "java+variable";
public bool isField(loc entity) = entity.scheme == "java+field";
public bool isInterface(loc entity) = entity.scheme == "java+interface";
public bool isEnum(loc entity) = entity.scheme == "java+enum";

public set[loc] files(rel[loc, loc] containment) 
  = {e.lhs | tuple[loc lhs, loc rhs] e <- containment, isCompilationUnit(e.lhs)};

public rel[loc, loc] declaredMethods(M3 m, set[Modifier] checkModifiers = {}) {
    declaredClasses = classes(m);
    methodModifiersMap = toMap(m.modifiers);
    
    return {e | tuple[loc lhs, loc rhs] e <- domainR(m.containment, declaredClasses), isMethod(e.rhs), checkModifiers <= (methodModifiersMap[e.rhs]? ? methodModifiersMap[e.rhs] : {}) };
}

public rel[loc, loc] declaredFields(M3 m, set[Modifier] checkModifiers = {}) {
    declaredClasses = classes(m);
    methodModifiersMap = toMap(m.modifiers);
    return {e | tuple[loc lhs, loc rhs] e <- domainR(m.containment, declaredClasses), isField(e.rhs), checkModifiers <= (methodModifiersMap[e.rhs]? ? methodModifiersMap[e.rhs] : {}) };
}

public rel[loc, loc] declaredFieldsX(M3 m, set[Modifier] checkModifiers = {}) {
    declaredClasses = classes(m);
    methodModifiersMap = toMap(m.modifiers);
    
    return {e | tuple[loc lhs, loc rhs] e <- domainR(m.containment, declaredClasses), isField(e.rhs), isEmpty(checkModifiers & (methodModifiersMap[e.rhs]? ? methodModifiersMap[e.rhs] : {})) };
} 
 
public rel[loc, loc] declaredTopTypes(M3 m)  
  = {e | tuple[loc lhs, loc rhs] e <- m.containment, isCompilationUnit(e.lhs), isClass(e.rhs) || isInterface(e.rhs)}; 

public rel[loc, loc] declaredSubTypes(M3 m) 
  = {e | tuple[loc lhs, loc rhs] e <- m.containment, isClass(e.rhs)} - declaredTopTypes(m);


@memo public set[loc] classes(M3 m) =  {e | <e,_> <- m.declarations, isClass(e)};
@memo public set[loc] interfaces(M3 m) =  {e | <e,_> <- m.declarations, isInterface(e)};
@memo public set[loc] packages(M3 m) = {e | <e,_> <- m.declarations, isPackage(e)};
@memo public set[loc] variables(M3 m) = {e | <e,_> <- m.declarations, isVariable(e)};
@memo public set[loc] parameters(M3 m)  = {e | <e,_> <- m.declarations, isParameter(e)};
@memo public set[loc] fields(M3 m) = {e | <e,_> <- m.declarations, isField(e)};
@memo public set[loc] methods(M3 m) = {e | <e,_> <- m.declarations, isMethod(e)};
@memo public set[loc] constructors(M3 m) = {e | <e,_> <- m.declarations, isConstructor(e)};
@memo public set[loc] enums(M3 m) = {e | <e,_> <- m.declarations, isEnum(e)};

public set[loc] elements(M3 m, loc parent) = m.containment[parent];

@memo public set[loc] fields(M3 m, loc class) = { e | e <- elements(m, class), isField(e) };
@memo public set[loc] methods(M3 m, loc class) = { e | e <- elements(m, class), isMethod(e) };
@memo public set[loc] constructors(M3 m, loc class) = { e | e <- elements(m, class), isConstructor(e) };
@memo public set[loc] nestedClasses(M3 m, loc class) = { e | e <- elements(m, class), isClass(e) };