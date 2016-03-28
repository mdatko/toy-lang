{
	function getOperatorPriority(operator) {
    	var binaryOperatorPriority = {
        	"*": 3,
          	"/": 3,
          	"^": 3,
          	"&&": 3,

	          ".": 2,
	          "+": 2,
	          "-": 2,
	          "||": 2,

	          ">=": 1,
	          "<=": 1,
	          ">": 1,
	          "<": 1,

	          "!=": 0,
	          "=": 0
	    };
		return binaryOperatorPriority[operator];
	}
}

Program
	= _ statement:ProgramStatement* _ {
    	return statement;
    }

ProgramStatement
	= _ command:Command _ { return command; }
    / _ functionDeclaration:FunctionDeclaration _ { return functionDeclaration; }

FunctionName = Identifier { return text(); }

FunctionCall
	= functionName:FunctionName _ "(" _ functionArguments:FunctionArguments _ ")" {
    	return {
        	type: "function",
        	name: functionName,
            arguments: functionArguments
        };
    }

FunctionDeclaration
	= FunctionName _ "(" _ FunctionArguments _ ")" _ "{" _ Command* _ "}"

FunctionArguments
	= FunctionArgument ("," FunctionArgument)+ / FunctionArgument / _

FunctionArgument
	= FunctionCall / Expression

Command
	= _ controlCommand:ControlCommand _ {
    	return controlCommand;
    }
    / _ assignment:Assignment _ ";" _ {
    	return assignment;
    }
    / _ functionCall:FunctionCall _ ";" _ {
    	return functionCall;
    }

ControlCommand
	= IfStatement / WhileStatement / ForStatement

BlockCommand
	= "{" _ command:Command* "}" {
    	return command;
    }
    / command:Command {
    	return [command];
    }

/* if-then */
IfStatement
	= "if" _ "(" _ ifExpression:Expression _ ")" _ ifClause:BlockCommand _ elseClause:ElseClause? {
    	console.log(elseClause);
    	return {
        	command: "if",
            expression: ifExpression,
            ifClause: ifClause,
            elseClause: (typeof elseClause !== "undefined") ? elseClause : null
        }
    }

/* else */
ElseClause
	= "else" _ command:BlockCommand { return command; }

/* while loop */
WhileStatement
	= "while" _ "(" _ expression:Expression _ ")" _ body:BlockCommand {
    	return {
        	command: "while",
            expression: expression,
            body: body
        };
    }

/* for loop */
ForStatement
	= "for" _ "(" _ init:Assignment? _ ";" _ expression:Expression? _ ";"? _ step:Assignment? _ ")" _ body:BlockCommand {
    	return {
        	command: "for",
            init: init,
            expression: expression,
            step: step,
            body:body
        }
    }

PrimaryExpression
	= FunctionCall
    / Variable
    / Constant
    / "(" _ expression:Expression _ ")" { return expression; }

UnaryExpression = operator:UnaryOperator? term:PrimaryExpression {
	if (typeof operator !== "undefined" && operator !== null) {
      return {
          operator: operator,
          type: "unary",
          operand: term
      }
    } else {
    	return term;
    }
}

MultiplicativeExpression
	= operand1:UnaryExpression _ operator:(Multiply / Divide / Mod / Power) _ operand2:UnaryExpression {
     	return {
        	operator: operator,
        	type: "binary",
        	operands: [operand1, operand2]
    	};
	}
    / UnaryExpression

AdditiveExpression
	= operand1:MultiplicativeExpression _ operator:(Add / Subtract) _ operand2:MultiplicativeExpression {
      return {
          operator: operator,
          type: "binary",
          operands: [operand1, operand2]
      };
	}
    / MultiplicativeExpression

RelationalExpression
	= operand1:AdditiveExpression _ operator:(GreaterOrEqual / LessOrEqual / Greater / Less) _ operand2:AdditiveExpression {
    	return {
        	operator: operator,
            type: "binary",
            operands: [operand1, operand2]
        };
    }
    / AdditiveExpression

EqualityExpression
	= operand1:RelationalExpression _ operator:(Equal / NotEqual) _ operand2:RelationalExpression {
    	return {
        	operator: operator,
            type: "binary",
            operands: [operand1, operand2]
        }
    }
    / RelationalExpression

AndExpression
	= operand1:EqualityExpression _ operator:(And) _ operand2:EqualityExpression {
    	return {
        	operator: operator,
            type: "binary",
            operands: [operand1, operand2]
        }
    }
    / EqualityExpression

OrExpression
	= operand1:AndExpression _ operator:(Or) _ operand2:AndExpression {
    	return {
        	operator: operator,
            type: "binary",
            operands: [operand1, operand2]
        }
    }
    / AndExpression

ConcatExpression
	= operand1:OrExpression _ operator:(Concat) _ operand2:OrExpression {
    	return {
        	operator: operator,
            type: "binary",
            operands: [operand1, operand2]
        }
    }
    / OrExpression

Expression = ConcatExpression

UnaryOperator = Not / NegativeValue

Not = "!" { return text(); }
NegativeValue = "-" { return text(); }

BinaryOperator
	= Concat
	/ Add
	/ Subtract
  	/ Multiply
  	/ Divide
    / Mod
    / Power
    / GreaterOrEqual
    / LessOrEqual
    / Greater
    / Less
    / Equal
    / NotEqual
    / And
    / Or

Concat = "." { return text(); }
Add = "+" { return text(); }
Subtract = "-" { return text(); }
Multiply = "*" { return text(); }
Divide = "/" { return text(); }
Mod = "%" { return text(); }
Power = "^" { return text(); }
GreaterOrEqual = ">=" { return text(); }
LessOrEqual = "<=" { return text(); }
Greater = ">" { return text(); }
Less = "<" { return text(); }
Equal = "==" { return text(); }
NotEqual = "!=" { return text(); }
And = "&&" { return text(); }
Or = "||" { return text(); }

Assignment "assigment"
	= variable:Variable _ "=" _ expression:Expression {
    	return {
        	command: "assign",
            variable: variable,
            expression: expression
        };
    }

Variable = Identifier {
	return {
      type: "variable",
      name: text()
	};
}

/* legal identifier */
Identifier = !Keyword [_a-zA-Z]+[_a-zA-Z0-9]*

Keyword
	= "if" / "for" / "while" / "continue" / "break" / "true" / "false" / "switch" / "default" / "do" / "case"

/* constant value */
Constant = QuotedString / Boolean / Float / Integer

/* boolean constant */
Boolean
	= "true" {
    	return {
          type: "value",
          dataType: "boolean",
          value: true
    	};
    }
    / "false" {
    	return {
          type: "value",
          dataType: "boolean",
          value: false
      	};
    }

/* floatin point number constant */
Float
	= [0-9]+"."[0-9]+ {
    	return {
        	type: "value",
            dataType: "float",
            value: text()
        }
    }

/* integer constant */
Integer
	= [0-9]+ {
    	return {
    		type: "value",
            dataType: "integer",
        	value: text()
      	};
	}

/* quoted string constant */
QuotedString
  = '"' quote:NotQuote* '"' {
	return	{
    	type: "value",
        dataType: "string",
    	value: quote.join("")
    }
  }

NotQuote = !'"' char: . { return char; }

/* whitespace, comments, non-executed things */
_ = (WhiteSpace / BlockComment / LineComment)*

WhiteSpace = [ \n\r\t] { return null; }

LineComment = "//"  comment:([^\n]*)  {
	return {
        type: "line-comment",
        text: comment.join("")
    }
}

BlockComment = "/*" comment:(!"*/" .)* "*/" {
	return {
		type: "block-comment",
		text: comment.reduce(function (acc, curr) { return acc + curr[1]; }, "")
    }
}
