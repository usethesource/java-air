package org.rascalmpl.library.lang.java.m3.internal;

import java.util.Iterator;
import java.util.Map;

import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.AbstractTypeDeclaration;
import org.eclipse.jdt.core.dom.AnnotationTypeDeclaration;
import org.eclipse.jdt.core.dom.AnnotationTypeMemberDeclaration;
import org.eclipse.jdt.core.dom.AnonymousClassDeclaration;
import org.eclipse.jdt.core.dom.ArrayAccess;
import org.eclipse.jdt.core.dom.ArrayCreation;
import org.eclipse.jdt.core.dom.ArrayInitializer;
import org.eclipse.jdt.core.dom.ArrayType;
import org.eclipse.jdt.core.dom.AssertStatement;
import org.eclipse.jdt.core.dom.Assignment;
import org.eclipse.jdt.core.dom.Block;
import org.eclipse.jdt.core.dom.BlockComment;
import org.eclipse.jdt.core.dom.BodyDeclaration;
import org.eclipse.jdt.core.dom.BooleanLiteral;
import org.eclipse.jdt.core.dom.BreakStatement;
import org.eclipse.jdt.core.dom.CastExpression;
import org.eclipse.jdt.core.dom.CatchClause;
import org.eclipse.jdt.core.dom.CharacterLiteral;
import org.eclipse.jdt.core.dom.ClassInstanceCreation;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.ConditionalExpression;
import org.eclipse.jdt.core.dom.ConstructorInvocation;
import org.eclipse.jdt.core.dom.ContinueStatement;
import org.eclipse.jdt.core.dom.DoStatement;
import org.eclipse.jdt.core.dom.EmptyStatement;
import org.eclipse.jdt.core.dom.EnhancedForStatement;
import org.eclipse.jdt.core.dom.EnumConstantDeclaration;
import org.eclipse.jdt.core.dom.EnumDeclaration;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.ExpressionStatement;
import org.eclipse.jdt.core.dom.FieldAccess;
import org.eclipse.jdt.core.dom.FieldDeclaration;
import org.eclipse.jdt.core.dom.ForStatement;
import org.eclipse.jdt.core.dom.IBinding;
import org.eclipse.jdt.core.dom.IMethodBinding;
import org.eclipse.jdt.core.dom.ITypeBinding;
import org.eclipse.jdt.core.dom.IVariableBinding;
import org.eclipse.jdt.core.dom.IfStatement;
import org.eclipse.jdt.core.dom.ImportDeclaration;
import org.eclipse.jdt.core.dom.InfixExpression;
import org.eclipse.jdt.core.dom.Initializer;
import org.eclipse.jdt.core.dom.InstanceofExpression;
import org.eclipse.jdt.core.dom.Javadoc;
import org.eclipse.jdt.core.dom.LabeledStatement;
import org.eclipse.jdt.core.dom.LineComment;
import org.eclipse.jdt.core.dom.MarkerAnnotation;
import org.eclipse.jdt.core.dom.MemberRef;
import org.eclipse.jdt.core.dom.MemberValuePair;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.MethodRef;
import org.eclipse.jdt.core.dom.MethodRefParameter;
import org.eclipse.jdt.core.dom.Modifier;
import org.eclipse.jdt.core.dom.Name;
import org.eclipse.jdt.core.dom.NormalAnnotation;
import org.eclipse.jdt.core.dom.NullLiteral;
import org.eclipse.jdt.core.dom.NumberLiteral;
import org.eclipse.jdt.core.dom.PackageDeclaration;
import org.eclipse.jdt.core.dom.ParameterizedType;
import org.eclipse.jdt.core.dom.ParenthesizedExpression;
import org.eclipse.jdt.core.dom.PostfixExpression;
import org.eclipse.jdt.core.dom.PrefixExpression;
import org.eclipse.jdt.core.dom.PrimitiveType;
import org.eclipse.jdt.core.dom.QualifiedName;
import org.eclipse.jdt.core.dom.QualifiedType;
import org.eclipse.jdt.core.dom.ReturnStatement;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.SimpleType;
import org.eclipse.jdt.core.dom.SingleMemberAnnotation;
import org.eclipse.jdt.core.dom.SingleVariableDeclaration;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.StringLiteral;
import org.eclipse.jdt.core.dom.SuperConstructorInvocation;
import org.eclipse.jdt.core.dom.SuperFieldAccess;
import org.eclipse.jdt.core.dom.SuperMethodInvocation;
import org.eclipse.jdt.core.dom.SwitchCase;
import org.eclipse.jdt.core.dom.SwitchStatement;
import org.eclipse.jdt.core.dom.SynchronizedStatement;
import org.eclipse.jdt.core.dom.TagElement;
import org.eclipse.jdt.core.dom.TextElement;
import org.eclipse.jdt.core.dom.ThisExpression;
import org.eclipse.jdt.core.dom.ThrowStatement;
import org.eclipse.jdt.core.dom.TryStatement;
import org.eclipse.jdt.core.dom.Type;
import org.eclipse.jdt.core.dom.TypeDeclaration;
import org.eclipse.jdt.core.dom.TypeDeclarationStatement;
import org.eclipse.jdt.core.dom.TypeLiteral;
import org.eclipse.jdt.core.dom.TypeParameter;
import org.eclipse.jdt.core.dom.UnionType;
import org.eclipse.jdt.core.dom.VariableDeclaration;
import org.eclipse.jdt.core.dom.VariableDeclarationExpression;
import org.eclipse.jdt.core.dom.VariableDeclarationFragment;
import org.eclipse.jdt.core.dom.VariableDeclarationStatement;
import org.eclipse.jdt.core.dom.WhileStatement;
import org.eclipse.jdt.core.dom.WildcardType;
import org.rascalmpl.value.ISourceLocation;
import org.rascalmpl.value.IValue;
import org.rascalmpl.value.type.TypeStore;

@SuppressWarnings({"rawtypes", "deprecation"})
public class ASTConverter extends JavaToRascalConverter {
	/* 
	 * TODO:
	 * Type parameters need to come out of annotations
	 * calls may need to be broken up into superconstructor, constructor, supermethod, method calls or separate them in bindings
	 */
	public ASTConverter(final TypeStore typeStore, Map<String, ISourceLocation> cache, boolean collectBindings) {
		super(typeStore, cache, collectBindings);
	}
	
	public void postVisit(ASTNode node) {
		setAnnotation("src", getSourceLocation(node));
		ISourceLocation decl = resolveBinding(node);
		if (!decl.getScheme().equals("unknown")) {
		  setAnnotation("decl", decl); 
		}
		setAnnotation("typ", resolveType(node));
	}
	
	private IValue resolveType(ASTNode node) {
	  try {
		  if (node instanceof Expression) {
			if (node instanceof Name) {
				IBinding b = ((Name) node).resolveBinding();
				return bindingsResolver.resolveType(b, false);
			}
		    ITypeBinding binding = ((Expression) node).resolveTypeBinding();
		    return bindingsResolver.resolveType(binding, false);
		  }
		  else if (node instanceof TypeDeclaration) {
		    ITypeBinding binding = ((TypeDeclaration) node).resolveBinding();
		    return bindingsResolver.resolveType(binding, true);
		  }
		  else if (node instanceof MethodDeclaration) {
		    IMethodBinding binding = ((MethodDeclaration) node).resolveBinding();
	        return bindingsResolver.resolveType(binding, true);
		  }
		  else if (node instanceof VariableDeclaration) {
		    IVariableBinding binding = ((VariableDeclaration) node).resolveBinding();
		    return bindingsResolver.resolveType(binding.getType(), false);
		  }
	  } catch (NullPointerException e) {
		  System.err.println("Got NPE for node " + node);
	  }
	  
	  return null;
  }

  public boolean visit(AnnotationTypeDeclaration node) {
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		IValue name = values.string(node.getName().getFullyQualifiedName());
		
		IValueList bodyDeclarations = new IValueList(values);
		for (Iterator it = node.bodyDeclarations().iterator(); it.hasNext();) {
			BodyDeclaration d = (BodyDeclaration) it.next();
			bodyDeclarations.add(visitChild(d));
		}
	
		ownValue = constructDeclarationNode("annotationType", name, bodyDeclarations.asList());
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(AnnotationTypeMemberDeclaration node) {
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		IValue typeArgument = visitChild(node.getType());
		
		String name = node.getName().getFullyQualifiedName();
		
		IValue defaultBlock = node.getDefault() == null ? null : visitChild(node.getDefault());
		ownValue = constructDeclarationNode("annotationTypeMember", typeArgument, values.string(name), defaultBlock);
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(AnonymousClassDeclaration node) {
		IValueList bodyDeclarations = new IValueList(values);
	
		for (Iterator it = node.bodyDeclarations().iterator(); it.hasNext();) {
			BodyDeclaration b = (BodyDeclaration) it.next();
			bodyDeclarations.add(visitChild(b));
		}
		ownValue = constructDeclarationNode("class", bodyDeclarations.asList());
		
		return false;
	}
	
	public boolean visit(ArrayAccess node) {
		IValue array = visitChild(node.getArray());
		IValue index = visitChild(node.getIndex());
		
		ownValue = constructExpressionNode("arrayAccess", array, index);
	
		return false;
	}
	
	public boolean visit(ArrayCreation node) {
		IValue type = visitChild(node.getType().getElementType());
	
		IValueList dimensions = new IValueList(values);
		for (Iterator it = node.dimensions().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			dimensions.add(visitChild(e));
		}
	
		IValue initializer = node.getInitializer() == null ? null : visitChild(node.getInitializer());
		
		ownValue = constructExpressionNode("newArray", type, dimensions.asList(), initializer);
		
		return false;
	}
	
	public boolean visit(ArrayInitializer node) {
		IValueList expressions = new IValueList(values);
		for (Iterator it = node.expressions().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			expressions.add(visitChild(e));
		}
		
		ownValue = constructExpressionNode("arrayInitializer", expressions.asList());
		
		return false;
	}
	
	public boolean visit(ArrayType node) {
		IValue type = visitChild(node.getComponentType());
		
		ownValue = constructTypeNode("arrayType", type);
		
		return false;
	}
	
	public boolean visit(AssertStatement node) {
		IValue expression = visitChild(node.getExpression());
		IValue message = node.getMessage() == null ? null : visitChild(node.getMessage());
		
		ownValue = constructStatementNode("assert", expression, message);
		
		return false;
	}
	
	public boolean visit(Assignment node) {
		IValue leftSide = visitChild(node.getLeftHandSide());
		IValue rightSide = visitChild(node.getRightHandSide());
		
		ownValue = constructExpressionNode("assignment", leftSide, values.string(node.getOperator().toString()), rightSide);
		
		return false;
	}
	
	public boolean visit(Block node) {
		IValueList statements = new IValueList(values);
		for (Iterator it = node.statements().iterator(); it.hasNext();) {
			Statement s = (Statement) it.next();
			statements.add(visitChild(s));
		}
		
		ownValue = constructStatementNode("block", statements.asList());
		
		return false;
	}
	
	public boolean visit(BlockComment node) {
		return false;
	}
	
	public boolean visit(BooleanLiteral node) {
		IValue booleanValue = values.bool(node.booleanValue());
		
		ownValue = constructExpressionNode("booleanLiteral", booleanValue);
		
		return false;
	}
	
	public boolean visit(BreakStatement node) {
		IValue label = node.getLabel() == null ? values.string("") : values.string(node.getLabel().getFullyQualifiedName());
		ownValue = constructStatementNode("break", label);
		
		return false;
	}
	
	public boolean visit(CastExpression node) {
		IValue type = visitChild(node.getType());
		IValue expression = visitChild(node.getExpression());
		
		ownValue = constructExpressionNode("cast", type, expression);
		
		return false;
	}
	
	public boolean visit(CatchClause node) {
		IValue exception = visitChild(node.getException());
		IValue body = visitChild(node.getBody());
		
		ownValue = constructStatementNode("catch", exception, body);
		
		return false;
	}
	
	public boolean visit(CharacterLiteral node) {
		IValue value = values.string(node.getEscapedValue()); 
		
		ownValue = constructExpressionNode("characterLiteral", value);
		
		return false;
	}
	
	public boolean visit(ClassInstanceCreation node) {
		IValue expression = node.getExpression() == null ? null : visitChild(node.getExpression());
	
		IValue type = null;
		IValueList genericTypes = new IValueList(values);
		if (node.getAST().apiLevel() == AST.JLS2) {
			type = visitChild(node.getName());
		} 
		else {
			type = visitChild(node.getType()); 
	
			if (!node.typeArguments().isEmpty()) {
				for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					genericTypes.add(visitChild(t));
				}
			}
		}
	
		IValueList arguments = new IValueList(values);
		for (Iterator it = node.arguments().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			arguments.add(visitChild(e));
		}
	
		IValue anonymousClassDeclaration = node.getAnonymousClassDeclaration() == null ? null : visitChild(node.getAnonymousClassDeclaration());
		
		ownValue = constructExpressionNode("newObject", expression, type, arguments.asList(), anonymousClassDeclaration);
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(CompilationUnit node) {
		IValue packageOfUnit = node.getPackage() == null ? null : visitChild(node.getPackage());
		
		IValueList imports = new IValueList(values);
		for (Iterator it = node.imports().iterator(); it.hasNext();) {
			ImportDeclaration d = (ImportDeclaration) it.next();
			imports.add(visitChild(d));
		}
	
		IValueList typeDeclarations = new IValueList(values);
		for (Iterator it = node.types().iterator(); it.hasNext();) {
			AbstractTypeDeclaration d = (AbstractTypeDeclaration) it.next();
			typeDeclarations.add(visitChild(d));
		}
		
		ownValue = constructDeclarationNode("compilationUnit", packageOfUnit, imports.asList(), typeDeclarations.asList());		
		return false;
	}
	
	public boolean visit(ConditionalExpression node) {
		IValue expression = visitChild(node.getExpression());
		IValue thenBranch = visitChild(node.getThenExpression());
		IValue elseBranch = visitChild(node.getElseExpression());
		
		ownValue = constructExpressionNode("conditional", expression, thenBranch, elseBranch);
		
		return false;
	}
	
	public boolean visit(ConstructorInvocation node) {
		IValueList types = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeArguments().isEmpty()) {
	
				for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					types.add(visitChild(t));
				}
			}
		}
	
		IValueList arguments = new IValueList(values);
		for (Iterator it = node.arguments().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			arguments.add(visitChild(e));
		}
		
		ownValue = constructStatementNode("constructorCall", values.bool(false),  arguments.asList());
		setAnnotation("typeParameters", types);
		
		return false;
	}
	
	public boolean visit(ContinueStatement node) {
		
		IValue label = node.getLabel() == null ? null : values.string(node.getLabel().getFullyQualifiedName());
		ownValue = constructStatementNode("continue", label);
		
		return false;
	}
	
	public boolean visit(DoStatement node) {
		
		IValue body = visitChild(node.getBody());
		IValue whileExpression = visitChild(node.getExpression());
	
		ownValue = constructStatementNode("do", body, whileExpression);
		
		return false;
	}
	
	public boolean visit(EmptyStatement node) {
		
		ownValue = constructStatementNode("empty");
		
		return false;
	}
	
	public boolean visit(EnhancedForStatement node) {
		
		IValue parameter = visitChild(node.getParameter());
		IValue collectionExpression = visitChild(node.getExpression());
		IValue body = visitChild(node.getBody());
	
		ownValue = constructStatementNode("foreach", parameter, collectionExpression, body);
		
		return false;
	}
	
	public boolean visit(EnumConstantDeclaration node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		IValue name = values.string(node.getName().getFullyQualifiedName()); 
	
		IValueList arguments = new IValueList(values);
		if (!node.arguments().isEmpty()) {
			for (Iterator it = node.arguments().iterator(); it.hasNext();) {
				Expression e = (Expression) it.next();
				arguments.add(visitChild(e));
			}
		}
	
		IValue anonymousClassDeclaration = node.getAnonymousClassDeclaration() == null ? null : visitChild(node.getAnonymousClassDeclaration());
		
		ownValue = constructDeclarationNode("enumConstant", name, arguments.asList(), anonymousClassDeclaration);
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(EnumDeclaration node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		IValue name = values.string(node.getName().getFullyQualifiedName()); 
	
		IValueList implementedInterfaces = new IValueList(values);
		if (!node.superInterfaceTypes().isEmpty()) {
			for (Iterator it = node.superInterfaceTypes().iterator(); it.hasNext();) {
				Type t = (Type) it.next();
				implementedInterfaces.add(visitChild(t));
			}
		}
	
		IValueList enumConstants = new IValueList(values);
		for (Iterator it = node.enumConstants().iterator(); it.hasNext();) {
			EnumConstantDeclaration d = (EnumConstantDeclaration) it.next();
			enumConstants.add(visitChild(d));
		}
	
		IValueList bodyDeclarations = new IValueList(values);
		if (!node.bodyDeclarations().isEmpty()) {
			for (Iterator it = node.bodyDeclarations().iterator(); it.hasNext();) {
				BodyDeclaration d = (BodyDeclaration) it.next();
				bodyDeclarations.add(visitChild(d));
			}
		}
	
		ownValue = constructDeclarationNode("enum", name, implementedInterfaces.asList(), enumConstants.asList(), bodyDeclarations.asList());
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(ExpressionStatement node) {
		
		IValue expression = visitChild(node.getExpression());
		ownValue = constructStatementNode("expressionStatement", expression);
		
		return false;
	}
	
	public boolean visit(FieldAccess node) {
		
		IValue expression = visitChild(node.getExpression());
		IValue name = values.string(node.getName().getFullyQualifiedName());
	
		ownValue = constructExpressionNode("fieldAccess", values.bool(false), expression, name);
		
		return false;
	}
	
	public boolean visit(FieldDeclaration node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node);
		IValue type = visitChild(node.getType());
	
		IValueList fragments = new IValueList(values);
		for (Iterator it = node.fragments().iterator(); it.hasNext();) {
			VariableDeclarationFragment f = (VariableDeclarationFragment) it.next();
			fragments.add(visitChild(f));
		}
		
		ownValue = constructDeclarationNode("field", type, fragments.asList());
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(ForStatement node) {
		
		IValueList initializers = new IValueList(values);
		for (Iterator it = node.initializers().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			initializers.add(visitChild(e));
		}
	
		IValue booleanExpression = node.getExpression() == null ? null : visitChild(node.getExpression());
	
		IValueList updaters = new IValueList(values);
		for (Iterator it = node.updaters().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			updaters.add(visitChild(e));
		}
	
		IValue body = visitChild(node.getBody());
	
		ownValue = constructStatementNode("for", initializers.asList(), booleanExpression, updaters.asList(), body);
		
		return false;
	}
	
	public boolean visit(IfStatement node) {
		
		IValue booleanExpression = visitChild(node.getExpression());
		IValue thenStatement = visitChild(node.getThenStatement());
		IValue elseStatement = node.getElseStatement() == null ? null : visitChild(node.getElseStatement());
	
		ownValue = constructStatementNode("if", booleanExpression, thenStatement, elseStatement);
		
		return false;
	}
	
	public boolean visit(ImportDeclaration node) {
		
		String name = node.getName().getFullyQualifiedName();

		IValueList importModifiers = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (node.isStatic())
				importModifiers.add(constructModifierNode("static"));

			if (node.isOnDemand())
				importModifiers.add(constructModifierNode("onDemand"));
		}
		
		ownValue = constructDeclarationNode("import", values.string(name));
		setAnnotation("modifiers", importModifiers);
		
		return false;
	}
	
	public boolean visit(InfixExpression node) {
		
		IValue operator = values.string(node.getOperator().toString());
		IValue leftSide = visitChild(node.getLeftOperand());
		IValue rightSide = visitChild(node.getRightOperand());
		
		IValue intermediateExpression = constructExpressionNode("infix", leftSide, operator, rightSide);
		for (Iterator it = node.extendedOperands().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			intermediateExpression = constructExpressionNode("infix", intermediateExpression, operator, visitChild(e));
		}
		
		ownValue = intermediateExpression;
		
		return false;
	}
	
	public boolean visit(Initializer node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node);
		IValue body = visitChild(node.getBody());
	
		ownValue = constructDeclarationNode("initializer", body);
		setAnnotation("modifiers", extendedModifiers);
		return false;
	}
	
	public boolean visit(InstanceofExpression node) {
		
		IValue leftSide = visitChild(node.getLeftOperand());
		IValue rightSide = visitChild(node.getRightOperand());
	
		ownValue = constructExpressionNode("instanceof", leftSide, rightSide);
		
		return false;
	}
	
	public boolean visit(Javadoc node) {
	
		return false;
	}
	
	public boolean visit(LabeledStatement node) {
		
		IValue label = values.string(node.getLabel().getFullyQualifiedName());
		IValue body = visitChild(node.getBody());
	
		ownValue = constructStatementNode("label", label, body);
		
		return false;
	}
	
	public boolean visit(LineComment node) {
	
		return false;
	}
	
	public boolean visit(MarkerAnnotation node) {
		
		IValue typeName = values.string(node.getTypeName().getFullyQualifiedName());
		ownValue = constructExpressionNode("markerAnnotation", typeName);
		
		return false;
	}
	
	public boolean visit(MemberRef node) {
		return false;
	}
	
	public boolean visit(MemberValuePair node) {
		
		IValue name = values.string(node.getName().getFullyQualifiedName());
		IValue value = visitChild(node.getValue());
	
		ownValue = constructExpressionNode("memberValuePair", name, value);
		
		return false;
	}
	
	public boolean visit(MethodDeclaration node) {
		String constructorName = "method";
		IValueList extendedModifiers = parseExtendedModifiers(node);
		
		IValueList genericTypes = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeParameters().isEmpty()) {
				for (Iterator it = node.typeParameters().iterator(); it.hasNext();) {
					TypeParameter t = (TypeParameter) it.next();
					genericTypes.add(visitChild(t));
				}
			}
		}
	
		IValue returnType = null;
		if (!node.isConstructor()) {
			if (node.getAST().apiLevel() == AST.JLS2) {
				returnType = visitChild(node.getReturnType());
			} else if (node.getReturnType2() != null) {
				returnType = visitChild(node.getReturnType2());
			} else {
				
				
				returnType = constructTypeNode("void");
			}
		} else {
			constructorName = "constructor";
		}
		
		IValue name = values.string(node.getName().getFullyQualifiedName());
	
		IValueList parameters = new IValueList(values);
		for (Iterator it = node.parameters().iterator(); it.hasNext();) {
			SingleVariableDeclaration v = (SingleVariableDeclaration) it.next();
			parameters.add(visitChild(v));
		}
	
		IValueList possibleExceptions = new IValueList(values);
		if (!node.thrownExceptions().isEmpty()) {
	
			for (Iterator it = node.thrownExceptions().iterator(); it.hasNext();) {
				Name n = (Name) it.next();
				possibleExceptions.add(visitChild(n));
			}
		}
	
		IValue body = node.getBody() == null ? null : visitChild(node.getBody()); 
	
		ownValue = constructDeclarationNode(constructorName, returnType, name, parameters.asList(), possibleExceptions.asList(), body);
		setAnnotation("modifiers", extendedModifiers);
		// FIXME: this doesn't seem to be in use anymore
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(MethodInvocation node) {
		
		IValue expression = node.getExpression() == null ? null : visitChild(node.getExpression());
		
		IValueList genericTypes = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeArguments().isEmpty()) {
				for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					genericTypes.add(visitChild(t));
				}
			}
		}
	
		IValue name = values.string(node.getName().getFullyQualifiedName());
	
		IValueList arguments = new IValueList(values);
		for (Iterator it = node.arguments().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			arguments.add(visitChild(e));
		}		
		
		ownValue = constructExpressionNode("methodCall", values.bool(false), expression, name, arguments.asList());
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(MethodRef node) {
		return false;
	}
	
	public boolean visit(MethodRefParameter node) {
		return false;
	}
	
	public boolean visit(Modifier node) {
		String modifier = node.getKeyword().toString();
		ownValue = constructModifierNode(modifier);
			
		return false;
	}
	
	public boolean visit(NormalAnnotation node) {
		
		IValue typeName = values.string(node.getTypeName().getFullyQualifiedName());
	
		IValueList memberValuePairs = new IValueList(values);
		for (Iterator it = node.values().iterator(); it.hasNext();) {
			MemberValuePair p = (MemberValuePair) it.next();
			memberValuePairs.add(visitChild(p));
		}
	
		ownValue = constructExpressionNode("normalAnnotation", typeName, memberValuePairs.asList());
		
		return false;
	}
	
	public boolean visit(NullLiteral node) {
		
		ownValue = constructExpressionNode("null");
		
		return false;
	}
	
	public boolean visit(NumberLiteral node) {
		
		IValue number = values.string(node.getToken());
	
		ownValue = constructExpressionNode("number", number);
		
		return false;
	}
	
	public boolean visit(PackageDeclaration node) {
		IValueList annotations = new IValueList(values);
		
		annotations = parseExtendedModifiers(node.annotations());
		
		ownValue = null;
		for (String component: node.getName().getFullyQualifiedName().split("\\.")) {
			if (ownValue == null) {
				ownValue = constructDeclarationNode("package", values.string(component));
				setAnnotation("decl", resolveBinding(component));
				continue;
			}
			ownValue = constructDeclarationNode("package", ownValue, values.string(component));
			setAnnotation("decl", resolveBinding(component));
		}
		
		setAnnotation("modifiers", annotations);
		return false;
	}
	
	public boolean visit(ParameterizedType node) {
		
		IValue type = visitChild(node.getType());
	
		IValueList genericTypes = new IValueList(values);
		for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
			Type t = (Type) it.next();
			genericTypes.add(visitChild(t));
		}
	
		ownValue = constructTypeNode("parameterizedType", type);
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(ParenthesizedExpression node) {
		
		IValue expression = visitChild(node.getExpression());
		ownValue = constructExpressionNode("bracket", expression);
		
		return false;
	}
	
	public boolean visit(PostfixExpression node) {
		
		IValue operand = visitChild(node.getOperand());
		IValue operator = values.string(node.getOperator().toString());
	
		ownValue = constructExpressionNode("postfix", operand, operator);
		
		return false;
	}
	
	public boolean visit(PrefixExpression node) {
		
		IValue operand = visitChild(node.getOperand());
		IValue operator = values.string(node.getOperator().toString());
	
		ownValue = constructExpressionNode("prefix", operator, operand);
		
		return false;
	}
	
	public boolean visit(PrimitiveType node) {
		ownValue = constructTypeNode(node.toString());
		
		return false;
	}
	
	public boolean visit(QualifiedName node) {
		
		IValue qualifier = visitChild(node.getQualifier());
		
		
		IValue name = visitChild(node.getName());
		
		ownValue = constructExpressionNode("qualifiedName", qualifier, name);
		
		return false;
	}
	
	public boolean visit(QualifiedType node) {
		
		IValue qualifier = visitChild(node.getQualifier());
		
		
		IValue name = visitChild(node.getName());
		
		ownValue = constructTypeNode("qualifiedType", qualifier, name);
		
		return false;
	}
	
	public boolean visit(ReturnStatement node) {
		
		IValue expression = node.getExpression() == null ? null : visitChild(node.getExpression());
		ownValue = constructStatementNode("return", expression);
		
		return false;
	}
	
	public boolean visit(SimpleName node) {
		
		IValue value = values.string(node.getFullyQualifiedName());
		
		ownValue = constructExpressionNode("simpleName", value);
		
		return false;
	}
	
	public boolean visit(SimpleType node) {
		IValue value = visitChild(node.getName());
		ownValue = constructTypeNode("simpleType", value);
		
		return false;
	}
	
	public boolean visit(SingleMemberAnnotation node) {
		
		IValue name = values.string(node.getTypeName().getFullyQualifiedName());
		IValue value = visitChild(node.getValue());
	
		ownValue = constructExpressionNode("singleMemberAnnotation", name, value);
		
		return false;
	}
	
	public boolean visit(SingleVariableDeclaration node) {
		
		IValue name = values.string(node.getName().getFullyQualifiedName());
	
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
	
		IValue type = visitChild(node.getType());
		IValue initializer = node.getInitializer() == null ? null : visitChild(node.getInitializer());
	
		ownValue = constructDeclarationNode("parameter", type, name, values.integer(node.getExtraDimensions()), initializer);
		if (node.getAST().apiLevel() >= AST.JLS3 && node.isVarargs())
			ownValue = constructDeclarationNode("vararg", type, name);
		
		setAnnotation("modifiers", extendedModifiers);
		
		return false;
	}
	
	public boolean visit(StringLiteral node) {
		
		IValue value = values.string(node.getEscapedValue());		
		ownValue = constructExpressionNode("stringLiteral", value);
		
		return false;
	}
	
	public boolean visit(SuperConstructorInvocation node) {
		
		IValue expression = node.getExpression() == null ? null : visitChild(node.getExpression());
	
		IValueList genericTypes = new IValueList(values);	
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeArguments().isEmpty()) {
				for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					genericTypes.add(visitChild(t));
				}
			}
		}
	
		IValueList arguments = new IValueList(values);
		for (Iterator it = node.arguments().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			arguments.add(visitChild(e));
		}
	
		ownValue = constructStatementNode("constructorCall", values.bool(true), expression, arguments.asList());
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(SuperFieldAccess node) {
		
		IValue qualifier = node.getQualifier() == null ? null : visitChild(node.getQualifier());
		IValue name = values.string((node.getName().getFullyQualifiedName()));
	
		ownValue = constructExpressionNode("fieldAccess", values.bool(true), qualifier, name);
		
		return false;
	}
	
	public boolean visit(SuperMethodInvocation node) {
		
		IValue qualifier = node.getQualifier() == null ? null : visitChild(node.getQualifier());
		
		IValueList genericTypes = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeArguments().isEmpty()) {
				for (Iterator it = node.typeArguments().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					genericTypes.add(visitChild(t));
				}
			}
		}
	
		IValue name = values.string(node.getName().getFullyQualifiedName());
	
		IValueList arguments = new IValueList(values);
		for (Iterator it = node.arguments().iterator(); it.hasNext();) {
			Expression e = (Expression) it.next();
			arguments.add(visitChild(e));
		}
	
		ownValue = constructExpressionNode("methodCall", values.bool(true), qualifier, name, arguments.asList());
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(SwitchCase node) {
		

		IValue expression = node.getExpression() == null ? null : visitChild(node.getExpression());
		String constructorName = "case";
		
		if (node.isDefault())
			constructorName = "defaultCase";
		
		ownValue = constructStatementNode(constructorName, expression);			
		
		return false;
	}
	
	public boolean visit(SwitchStatement node) {
		
		IValue expression = visitChild(node.getExpression());
	
		IValueList statements = new IValueList(values);
		for (Iterator it = node.statements().iterator(); it.hasNext();) {
			Statement s = (Statement) it.next();
			statements.add(visitChild(s));
		}
	
		ownValue = constructStatementNode("switch", expression, statements.asList());
		
		return false;
	}
	
	public boolean visit(SynchronizedStatement node) {
		
		IValue expression = visitChild(node.getExpression());
		IValue body = visitChild(node.getBody());
		
		ownValue = constructStatementNode("synchronizedStatement", expression, body);
		
		return false;
	}
	
	public boolean visit(TagElement node) {
		
		return false;
	}
	
	public boolean visit(TextElement node) {
		
		return false;
	}
	
	public boolean visit(ThisExpression node) {
		
		IValue qualifier = node.getQualifier() == null ? null : visitChild(node.getQualifier());
	
		ownValue = constructExpressionNode("this", qualifier);
		
		return false;
	}
	
	public boolean visit(ThrowStatement node) {
		
		IValue expression = visitChild(node.getExpression());
		
		ownValue = constructStatementNode("throw", expression);
		
		return false;
	}
	
	public boolean visit(TryStatement node) {
		
		IValue body = visitChild(node.getBody());
	
		IValueList catchClauses = new IValueList(values);
		for (Iterator it = node.catchClauses().iterator(); it.hasNext();) {
			CatchClause cc = (CatchClause) it.next();
			catchClauses.add(visitChild(cc));
		}
		
		IValue finallyBlock = node.getFinally() == null ? null : visitChild(node.getFinally()); 
		
		ownValue = constructStatementNode("try", body, catchClauses.asList(), finallyBlock);
		
		return false;
	}
	
	public boolean visit(TypeDeclaration node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node);
		String objectType = node.isInterface() ? "interface" : "class";
		IValue name = values.string(node.getName().getFullyQualifiedName()); 
		
		IValueList genericTypes = new IValueList(values);
		if (node.getAST().apiLevel() >= AST.JLS3) {
			if (!node.typeParameters().isEmpty()) {			
				for (Iterator it = node.typeParameters().iterator(); it.hasNext();) {
					TypeParameter t = (TypeParameter) it.next();
					genericTypes.add(visitChild(t));			
				}
			}
		}
		
		IValueList extendsClass = new IValueList(values);
		IValueList implementsInterfaces = new IValueList(values);
		
		if (node.getAST().apiLevel() == AST.JLS2) {
			if (node.getSuperclass() != null) {
				extendsClass.add(visitChild(node.getSuperclass()));
			}
			if (!node.superInterfaces().isEmpty()) {
				for (Iterator it = node.superInterfaces().iterator(); it.hasNext();) {
					Name n = (Name) it.next();
					implementsInterfaces.add(visitChild(n));
				}
			}
		} else if (node.getAST().apiLevel() >= AST.JLS3) {
			if (node.getSuperclassType() != null) {
				extendsClass.add(visitChild(node.getSuperclassType()));
			}
			if (!node.superInterfaceTypes().isEmpty()) {
				for (Iterator it = node.superInterfaceTypes().iterator(); it.hasNext();) {
					Type t = (Type) it.next();
					implementsInterfaces.add(visitChild(t));
				}
			}
		}
		
		IValueList bodyDeclarations = new IValueList(values);
		for (Iterator it = node.bodyDeclarations().iterator(); it.hasNext();) {
			BodyDeclaration d = (BodyDeclaration) it.next();
			bodyDeclarations.add(visitChild(d));
		}
		
		ownValue = constructDeclarationNode(objectType, name, extendsClass.asList(), implementsInterfaces.asList(), bodyDeclarations.asList());
		setAnnotation("modifiers", extendedModifiers);
		setAnnotation("typeParameters", genericTypes);
		return false;
	}
	
	public boolean visit(TypeDeclarationStatement node) {
		
		IValue typeDeclaration;
		if (node.getAST().apiLevel() == AST.JLS2) {
			typeDeclaration = visitChild(node.getTypeDeclaration());
		}
		else {
			typeDeclaration = visitChild(node.getDeclaration());
		}
		
		ownValue = constructStatementNode("declarationStatement", typeDeclaration);
		
		return false;
	}
	
	public boolean visit(TypeLiteral node) {
		
		IValue type = visitChild(node.getType());
	
		ownValue = constructExpressionNode("type", type);
		
		return false;
	}
	
	public boolean visit(TypeParameter node) {
		
		IValue name = values.string(node.getName().getFullyQualifiedName());
		
		IValueList extendsList = new IValueList(values);
		if (!node.typeBounds().isEmpty()) {
			for (Iterator it = node.typeBounds().iterator(); it.hasNext();) {
				Type t = (Type) it.next();
				extendsList.add(visitChild(t));
			}
		}
		
		ownValue = constructDeclarationNode("typeParameter", name, extendsList.asList());
		
		return false;
	}
	
	public boolean visit(UnionType node) {
		
		IValueList typesValues = new IValueList(values);
		for(Iterator types = node.types().iterator(); types.hasNext();) {
			Type type = (Type) types.next();
			typesValues.add(visitChild(type));
		}
		
		ownValue = constructTypeNode("unionType", typesValues.asList());
		
		return false;
	}
	
	public boolean visit(VariableDeclarationExpression node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		
		
		IValue type = visitChild(node.getType());
		
		IValueList fragments = new IValueList(values);
		for (Iterator it = node.fragments().iterator(); it.hasNext();) {
			VariableDeclarationFragment f = (VariableDeclarationFragment) it.next();
			fragments.add(visitChild(f));
		}
		
		ownValue = constructDeclarationNode("variables", type, fragments.asList());
		setAnnotation("modifiers", extendedModifiers);
		
		ownValue = constructExpressionNode("declarationExpression", ownValue);
		
		
		return false;
	}
	
	public boolean visit(VariableDeclarationFragment node) {
		
		IValue name = values.string(node.getName().getFullyQualifiedName());
		
		IValue initializer = node.getInitializer() == null ? null : visitChild(node.getInitializer());
		
		ownValue = constructExpressionNode("variable", name, values.integer(node.getExtraDimensions()), initializer);
		
		
		return false;
	}
	
	public boolean visit(VariableDeclarationStatement node) {
		
		IValueList extendedModifiers = parseExtendedModifiers(node.modifiers());
		
		
		IValue type = visitChild(node.getType());
	
		IValueList fragments = new IValueList(values);
		for (Iterator it = node.fragments().iterator(); it.hasNext();) {
			VariableDeclarationFragment f = (VariableDeclarationFragment) it.next();
			fragments.add(visitChild(f));
		}
		
		ownValue = constructDeclarationNode("variables", type, fragments.asList());
		setAnnotation("modifiers", extendedModifiers);
		
		ownValue = constructStatementNode("declarationStatement", ownValue);
		
		return false;
	}
	
	public boolean visit(WhileStatement node) {
		
		IValue expression = visitChild(node.getExpression());
		IValue body = visitChild(node.getBody());
		
		ownValue = constructStatementNode("while", expression, body);
		
		return false;
	}
	
	public boolean visit(WildcardType node) {
		//FIXME: upperbound/lowerbound that should have been type annotation are replaced by TypeSymbol
		IValue type = null;
		String name = "wildcard";
				
		if (node.getBound() != null) {
			type = visitChild(node.getBound());
			if (node.isUpperBound()) {
				name = "upperbound";
				
			} else {
				name = "lowerbound";
			}
		}
		ownValue = constructTypeNode(name, type);
		
		return false;
	}
}
