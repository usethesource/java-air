@license{
Copyright (c) 2009-2025, NWO-I Centrum Wiskunde & Informatica (CWI)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
module lang::java::m3::TypeSymbol

extend analysis::m3::TypeSymbol;

data Bound 
  = \super(list[TypeSymbol] bound)
  | \extends(list[TypeSymbol] bound)
  | \unbounded()
  ;
  
data TypeSymbol 
  = \class(loc decl, list[TypeSymbol] typeParameters)
  | \interface(loc decl, list[TypeSymbol] typeParameters)
  | \enum(loc decl)
  | \method(loc decl, list[TypeSymbol] typeParameters, TypeSymbol returnType, list[TypeSymbol] parameters)
  | \constructor(loc decl, list[TypeSymbol] parameters)
  | \typeParameter(loc decl, Bound upperbound) 
  | \typeArgument(loc decl)
  | \wildcard(Bound bound)
  | \capture(Bound bound, TypeSymbol wildcard)
  | \intersection(list[TypeSymbol] types)
  | \union(list[TypeSymbol] types)
  | \object()
  | \int()
  | \float()
  | \double()
  | \short()
  | \boolean()
  | \char()
  | \byte()
  | \long()
  | \void()
  | \null()
  | \array(TypeSymbol component, int dimension)
  | \typeVariable(loc decl)
  | \module(loc decl)
  ;  
  
default bool subtype(TypeSymbol s, TypeSymbol t) = s == t;

default TypeSymbol lub(TypeSymbol s, TypeSymbol t) = s == t ? s : object();  
