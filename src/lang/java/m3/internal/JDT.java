/*******************************************************************************
 * Copyright (c) 2009-2011 CWI
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   * Jurgen J. Vinju - Jurgen.Vinju@cwi.nl - CWI
 *   * Bas Basten - Bas.Basten@cwi.nl (CWI)
 *   * Jouke Stoel - Jouke.Stoel@cwi.nl (CWI)
 *   * Mark Hills - Mark.Hills@cwi.nl (CWI)
 *   * Arnold Lankamp - Arnold.Lankamp@cwi.nl
 *   * Anastasia Izmaylova - A.Izmaylova@cwi.nl - CWI
*******************************************************************************/
package org.rascalmpl.library.lang.java.m3.internal;

import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import org.eclipse.imp.pdb.facts.IBool;
import org.eclipse.imp.pdb.facts.ISet;
import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IValue;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.Comment;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.parser.gtd.io.InputConverter;

public class JDT {
    private final IValueFactory VF;
    private List<String> classPathEntries;
    private List<String> sourcePathEntries;
	
    public JDT(IValueFactory vf) {
    	this.VF = vf;
    	this.classPathEntries = new ArrayList<String>();
    	this.sourcePathEntries = new ArrayList<String>();
	}
    
    public void setEnvironmentOptions(ISet classPaths, ISet sourcePaths, IEvaluatorContext eval) {
    	classPathEntries.clear();
    	sourcePathEntries.clear();
    	for (IValue path: classPaths) {
    		try {
				classPathEntries.add(eval.getResolverRegistry().getResourceURI(((ISourceLocation) path).getURI()).getPath());
			} catch (IOException e) {
				throw RuntimeExceptionFactory.io(VF.string(e.getMessage()), null, null);
			}
    	}
    	
    	for (IValue path: sourcePaths) {
    		try {
				sourcePathEntries.add(eval.getResolverRegistry().getResourceURI(((ISourceLocation) path).getURI()).getPath());
			} catch (IOException e) {
				throw RuntimeExceptionFactory.io(VF.string(e.getMessage()), null, null);
			}
    	}
    }
    
    @SuppressWarnings("rawtypes")
	public IValue createM3FromFile(ISourceLocation loc, IString javaVersion, IEvaluatorContext eval) {
    	try {
    		CompilationUnit cu = this.getCompilationUnit(loc, true, javaVersion, eval);
    		
    		M3Converter converter = new M3Converter(eval.getHeap().getModule("lang::java::m3::JavaM3").getStore());
    		converter.set(cu);
    		converter.set(loc);
    		cu.accept(converter);
			for (Iterator it = cu.getCommentList().iterator(); it.hasNext(); ) {
				Comment comment = (Comment) it.next();
				comment.accept(converter);
			}
			
    		return converter.getModel();
    	}
    	catch (IOException e) {
    		throw RuntimeExceptionFactory.io(VF.string(e.getMessage()), null, null);
    	}
    }
    
	/*
	 * Creates Rascal ASTs for Java source files
	 */
	public IValue createAstFromFile(ISourceLocation loc, IBool collectBindings, IString javaVersion, IEvaluatorContext eval) {
		try {
			CompilationUnit cu;
			
			cu = this.getCompilationUnit(loc, collectBindings.getValue(), javaVersion, eval);
			ASTConverter converter = new ASTConverter(eval.getHeap().getModule("analysis::m3::AST").getStore(),
					collectBindings.getValue());
			converter.set(cu);
			converter.set(loc);
			cu.accept(converter);
			converter.insertCompilationUnitMessages();
			return converter.getValue();
		} catch (IOException e) {
			throw RuntimeExceptionFactory.io(VF.string(e.getMessage()), null, null);
		}
	}
	
	private CompilationUnit getCompilationUnit(ISourceLocation loc, boolean resolveBindings, IString javaVersion, IEvaluatorContext ctx) throws IOException {
		ASTParser parser = ASTParser.newParser(AST.JLS4);
		parser.setUnitName(loc.getURI().getPath());
		parser.setResolveBindings(resolveBindings);
		parser.setSource(getFileContents(loc, ctx));
		parser.setBindingsRecovery(true);
		parser.setStatementsRecovery(true);
		
		Hashtable<String, String> options = new Hashtable<String, String>();
		
		options.put(JavaCore.COMPILER_SOURCE, javaVersion.getValue());
		options.put(JavaCore.COMPILER_COMPLIANCE, javaVersion.getValue());
		
		parser.setCompilerOptions(options);
		
		parser.setEnvironment(classPathEntries.toArray(new String[classPathEntries.size()]), 
				  sourcePathEntries.toArray(new String[sourcePathEntries.size()]),
				  null, true);

		CompilationUnit cu = (CompilationUnit) parser.createAST(null);
		
		return cu;
	}
	
	private char[] getFileContents(ISourceLocation loc, IEvaluatorContext ctx) throws IOException {
	    loc = ctx.getHeap().resolveSourceLocation(loc);
	    
		char[] data;
		Reader textStream = null;
		
		try {
			textStream = ctx.getResolverRegistry().getCharacterReader(loc.getURI());
			data = InputConverter.toChar(textStream);
		}
		finally{
			if(textStream != null){
				textStream.close();
			}
		}
		return data;
	}
}
