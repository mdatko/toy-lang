Program
	= _ statement:(Command _ / FunctionDeclaration _ / BlockComment _)* {
    	return statement.reduce(function (acc, curr) {
        	acc.push(curr[0]);
        	return acc;
        }, []);
    }

BlockComment
	= "/*" comment:(!"*/" .)* "*/" {
    	return {
        	type: "block-comment",
            text: comment.reduce(function (acc, curr) { return acc + curr[1]; }, "")
    	}
    }

FunctionName
	= [_a-zA-Z]+[_a-zA-Z0-9]* { return text(); }

FunctionCall
	= FunctionName _ "(" _ FunctionArgument _ ("," FunctionArgument)* _ ")"

FunctionDeclaration
	= FunctionName _ "(" _ FunctionArgument _ ("," FunctionArgument)* _ ")" _ "{" _ Command* _ "}"

FunctionArgument
	= _ (FunctionCall _ / Expression _)?

Command
	= ControlCommand / (Assignment _ ";") / (FunctionCall _ ";")

ControlCommand
	= IfStatement / WhileStatement / ForStatement

BlockCommand
	= ("{" _ Command* _ "}") / Command

IfStatement
	= "if" _ "(" _ Expression _ ")" _ BlockCommand _ ("else" _ BlockCommand)?

WhileStatement
	= "while" _ "(" _ Expression _ ")" _ BlockCommand

ForStatement
	= "for" _ "(" _ Assignment? _ ";" _ Expression? _ ";"? _ Assignment? _ ")" _ BlockCommand

Expression
	= Term (_ BinaryOperator _ Term)*

BinaryOperator
	= ("." / "+" / "-" / "*" / "/" / "^" / ">=" / "<=" / ">" / "<" / "==")

Term
	= ("(" _ Expression _ ")") / Variable / Value

Assignment "assigment"
	= variable:Variable _ "=" _ expr:Expression {
    	return {
        	command: "assign",
            variable: variable,
            value: expr
        };
    }

Variable
	= [_a-zA-Z]+[_a-zA-Z0-9]* { return text(); }

Value
	= QuotedString / Integer

Integer
	= [-]?[0-9]+ { return parseInt(text()); }

QuotedString
  = '"' quote: NotQuote* '"' { return quote.join(""); }

NotQuote
  = !'"' char: . { return char; }

_ "whitespace"
  = [ \t\n\r]* { return null; }
