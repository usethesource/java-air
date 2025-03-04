@license{
Copyright (c) 2009-2025, NWO-I Centrum Wiskunde & Informatica (CWI)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}
module lang::java::m3::TypeHierarchy

import lang::java::m3::Core;

rel[loc from, loc to] getDeclaredTypeHierarchy(M3 model) {
  typeHierarchy = model.extends + model.implements;
  typesWithoutParent = classes(model) + interfaces(model) - typeHierarchy<from>;
  enumsWithoutParent = enums(model) - typeHierarchy<from>;
  
  return typeHierarchy
    + (typesWithoutParent - {|java+class:///java/lang/Object|}) * {|java+class:///java/lang/Object|}
    + (enumsWithoutParent - {|java+class:///java/lang/Object|, |java+class:///java/lang/Enum|}) * {|java+class:///java/lang/Enum|}
    + ((enums(model) != {}) ? {<|java+class:///java/lang/Enum|, |java+lang:///java/lang/Object|>} : {})
    ;
}

