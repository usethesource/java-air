@license{
Copyright (c) 2009-2025, NWO-I Centrum Wiskunde & Informatica (CWI)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
@synopsis{Regression tests and backward compatibility tests for AST construction and M3 extraction for Java}
module lang::java::tests::BasicM3Tests

import util::Reflective;
import List;
import Message;
import IO;
import util::FileSystem;
import util::Math;
import ValueIO;
import Node;
import String;
import lang::java::m3::Core;
import lang::java::m3::AST;

@synopsis{Unpack a test source zip in a temporary folder for downstream analysis.}
private loc unpackExampleProject(str name, loc projectZip) {
    targetRoot = |tmp:///<name>|;
    sourceRoot = projectZip[scheme = "jar+<projectZip.scheme>"][path = projectZip.path + "!/"];
    copy(sourceRoot, targetRoot, recursive=true, overwrite=true);

	return targetRoot;
}

// Static data for regression testing against the Hamcrest project
public loc hamcrestJar      = getResource("lang/java/tests/data/hamcrest-library-1.3.jar");
public loc hamcrestBinaryM3 = getResource("lang/java/tests/data/hamcrest-library-1.3-m3.bin");

// Static data for regression testing against the JUnit4 project
public loc junitSourceZip         = getResource("lang/java/tests/data/junit4-project-source.zip");
public loc junitBinaryM3          = getResource("lang/java/tests/data/junit4-m3s.bin");
public loc junitBinaryASTs        = getResource("lang/java/tests/data/junit4-asts.bin");
public loc junitProject           = unpackExampleProject("junit4", junitSourceZip);
public list[loc] junitClassPath   = [junitProject + "/lib/hamcrest-core-1.3.jar", junitProject + "/lib/hamcrest-library-1.3.jar"];
public list[loc] junitSourcePath  = [junitProject + "/src/main/java/", junitProject + "/src/test/java/" ];

// Static data for regression testing against the Snakes and Ladders project
public loc snakesAndLaddersSource      = getResource("lang/java/tests/data/snakes-and-ladders-project-source.zip");
public loc snakesAndLaddersBinaryM3    = getResource("lang/java/tests/data/snakes-and-ladders-m3s.bin");
public loc snakesAndLaddersBinaryAST   = getResource("lang/java/tests/data/snakes-and-ladders-asts.bin");
public loc snakesAndLaddersProject     = unpackExampleProject("snakes-and-ladders", snakesAndLaddersSource);
public list[loc] snakesClassPath       = [snakesAndLaddersProject + "jexample-4.5-391.jar"];
public list[loc] snakesSourcePath      = [snakesAndLaddersProject + "/src/"];

public bool OVERWRITE = false;

@synopsis{regression testing M3 on the JUnit project}
test bool junitM3RemainedTheSame() {
	reference = readBinaryValueFile(#M3, junitBinaryM3);
	root = junitProject;
	models = createM3sFromFiles(find(root + "src", "java"),
		sourcePath = junitSourcePath, 
		classPath = junitClassPath, 
		javaVersion = JLS13());
	result = composeJavaM3(|project://junit4|, models);

	if (OVERWRITE) {
		writeBinaryValueFile(junitBinaryM3, result);
	}

	return compareM3s(reference, result);
}

@synopsis{regression testing M3 on the Snakes-and-ladders project}
test bool snakesM3RemainedTheSame() {
	reference = readBinaryValueFile(#M3, snakesAndLaddersBinaryM3);
	root = snakesAndLaddersProject;

	models = createM3sFromFiles(find(root + "src", "java"),
		sourcePath = snakesSourcePath, 
		classPath = snakesClassPath, 
		javaVersion = JLS13());
	result = composeJavaM3(|project://snakes-and-ladders/|, models);

	if (OVERWRITE) {
		writeBinaryValueFile(snakesAndLaddersBinaryM3, result);
	}

	return compareM3s(reference, result);
}
  
@synopsis{regression testing ASTs on the Junit4 project}  
test bool junitASTsRemainedTheSame()  {
	reference = readBinaryValueFile(#set[Declaration], junitBinaryASTs);
	root = junitProject;

	asts = createAstsFromFiles(find(root + "src", "java"), true, 
		sourcePath = junitSourcePath, 
		classPath = junitClassPath, 
		javaVersion = JLS13());

	// Because java.lang.SecurityManager no longer exists in JLS13 and we are compiling
	// an older version of Junit4, we get unresolved decl's for all things related to SecurityManager.
	astNodeSpecification(asts, checkNameResolution=true, checkSourceLocation=true);

	if (OVERWRITE) {
		writeBinaryValueFile(junitBinaryASTs, asts);
	}

	return reference == asts;
}

@synopsis{regression testing ASTs on the Snakes and Ladders project}  	    
test bool snakesASTsRemainedTheSame() {
	reference = readBinaryValueFile(#set[Declaration], snakesAndLaddersBinaryAST);
	
	root = snakesAndLaddersProject;

	asts = createAstsFromFiles(find(root + "src", "java"), true, 
		sourcePath = junitSourcePath, 
		classPath = junitClassPath, 
		javaVersion = JLS13());

	astNodeSpecification(asts, checkNameResolution=true, checkSourceLocation=true);

	if (OVERWRITE) {
		writeBinaryValueFile(snakesAndLaddersBinaryAST, asts);
	}

	return reference == asts;
}

@synopsis{Regression testing M3 extraction from .class files from a Hamcrest Jar file}
test bool hamcrestJarM3RemainedTheSame() {
	reference = readBinaryValueFile(#M3, hamcrestBinaryM3);

	// move to a location that is the same on all build machines
	targetJar = |tmp:///| + hamcrestJar.file;
	copy(hamcrestJar, targetJar, overwrite=true);

	result = createM3FromJar(targetJar);
	if (OVERWRITE) {
		writeBinaryValueFile(hamcrestBinaryM3, result);
	}
	return compareM3s(reference, result);
}
	
@synopsis{Comparison and simplistic differential diagnosis between two M3 models}
public bool compareM3s(M3 a, M3 b) {
	bool compareMessages(Message a, Message b) {
		return "<a>" < "<b>";
	}

	ok = true;
	aKeys = getKeywordParameters(a);
	bKeys = getKeywordParameters(b);
	for (ak <- aKeys) {
	
		if (!(ak in bKeys)) {
			ok = false;
			println("<ak>  missing in reference");
			continue;
		}
		if (aKeys[ak] != bKeys[ak]) {
			if (set[value] aks := aKeys[ak] && set[value] bks := bKeys[ak]) {
				println("<ak>: Missing elements in relation to reference: ");
				iprintln(aks - bks, lineLimit=5);
				println("<ak>: Additional elements in relation to reference:");
				iprintln(bks - aks, lineLimit=5);
			}
			else if (list[Message] akl := aKeys[ak] && list[Message] bkl := bKeys[ak]) {
				// In case of different size tell the difference.
				if (size(akl) != size(bkl)) {
					println("Missing messages in relation to reference: ");
					iprintln(bkl - akl, lineLimit=5);
					println("Additional messages in relation to reference:: ");
					iprintln(akl - bkl, lineLimit=5);
				}
				//Otherwise, check if all values remain the same.
				else {
					akl = sort(akl, compareMessages);
					bkl = sort(bkl, compareMessages);
					if (akl == bkl) {
						//No worries, just sorting!;
						continue;
					}
					for (i <- [0..min(size(akl), 5)]) {
						if (akl[i] != bkl[i]) {
							println("The <i>th element differs.");
							iprintln([(akl[i]), (bkl[i])], lineLimit=5);
						}
					}
				}
			}

			ok = false;
			println("<ak> has a different value.");
		}
	}

	for (bk <- bKeys) {
		if (!(bk in aKeys)) {
			ok = false;
		  	println("<bk> missing in result");
		}
	}
	return ok;
}
