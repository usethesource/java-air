@license{
Copyright (c) 2009-2025, NWO-I Centrum Wiskunde & Informatica (CWI)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
@contributor{Davy Landman - Davy.Landman@cwi.nl - CWI}
@synopsis{Import this module to Disambiguate the ambiguity cause by the prefix operators +/- and infix operators +/-.
    An example of this ambiguity is (A) + (B) . This could be (A)(+ (B)) or`(A + B)`.
    We need to have a symbol table to decide if A is a type and thus a TypeCast, or it is a field/variable access.
    
    Java lacks operator overloading, therefore, prefix operators only work on numeric types.
    Moreover, there is no support for custom covariance and contravariance.
    Therefore, only if (A) is a primary/boxed numeric type can it be a prefix expression.
    
    We therefore have added this complete but not sound disambiguation as a separate module.
    
    These following cases will result in a incorrect parse tree:
    
    - Shadowing of Integer/Double/Float
    - An invalid type cast: (String)+(A) where A has a numeric type
      (This expression would be an uncompilable, and we would disambiguate it as a infix expression)}
module lang::java::\syntax::Disambiguate

import ParseTree;
import Relation;
import List;
import Set;
import lang::java::\syntax::Java15;

bool isNumeric((RefType)`Byte`) = true;
bool isNumeric((RefType)`java.lang.Byte`) = true;
bool isNumeric((RefType)`Character`) = true;
bool isNumeric((RefType)`java.lang.Character`) = true;
bool isNumeric((RefType)`Short`) = true;
bool isNumeric((RefType)`java.lang.Short`) = true;
bool isNumeric((RefType)`Integer`) = true;
bool isNumeric((RefType)`java.lang.Integer`) = true;
bool isNumeric((RefType)`Long`) = true;
bool isNumeric((RefType)`java.lang.Long`) = true;
bool isNumeric((RefType)`Float`) = true;
bool isNumeric((RefType)`java.lang.Float`) = true;
bool isNumeric((RefType)`Double`) = true;
bool isNumeric((RefType)`java.lang.Double`) = true;

default bool isNumeric(RefType r) = false;

bool isPrefix((Expr)`+ <Expr _>`) = true;
bool isPrefix((Expr)`++ <Expr _>`) = true;
bool isPrefix((Expr)`- <Expr _>`) = true;
bool isPrefix((Expr)`-- <Expr _>`) = true;
default bool isPrefix(Expr x) = false;

Tree amb(set[Tree] alts) {
	if (containsPrefixExpressions(alts)) {
		counts = {<size(casts), a> | a <- alts, casts := [ isNumeric(t) | /(Expr)`(<RefType t>) <Expr e>` := a, isPrefix(e)], size(casts) > 0 ==> all(c <- casts, c)};
		if (counts != {}) {
			// get the valid tree with the most valid casts
			return getOneFrom(counts[sort([*domain(counts)])[-1]]);
		}
	}
	fail amb;
}

bool containsPrefixExpressions(set[Tree] trees) {
	for (t <- trees) {
		if (containsPrefixExpression(t)) {
			return true;	
		}	
	}
	return false;
} 

bool containsPrefixExpression(Tree t) {
	todo = {t};
	while (todo != {}) {
		if ((Expr)`(<RefType _>) <Expr e>` <- todo && isPrefix(e)) {
			return true;	
		}
		todo = { *args | appl(_, args) <- todo};
	}
	return false;
}
