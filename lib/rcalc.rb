module Rcalc
  class Eval
    class UnexpectedNodeError < StandardError; end
    class UnexpectedCallExpressionError < StandardError; end

    OPERATORS = {
      add: ->(args) { args.inject { |sum, n| sum + n } },
      subtract: ->(args) { args.inject { |sum, n| sum - n } },
    }

    VARIABLES = {}

    def self.interpret(ast)
      ast.map { |node| self.process_node(node) }
        .select { |v| !v.to_s.empty? }
        .join("\n")
    end

    private

    def self.process_node(node)
      case node[:kind]
      when Parser::NUMBER_LITERAL
        return node[:value]
      when Parser::NAME_LITERAL
        # Return variable value by name
        return VARIABLES[node[:value]]
      when Parser::VARIABLE_DEFINITION
        # Set variable
        VARIABLES[node[:name][:value]] = node[:value][:value]
        return nil
      when Parser::CALL_EXPRESSION
        fn = OPERATORS[node[:name].to_sym]
        raise UnexpectedCallExpressionError, node.inspect if fn.nil?
        args = node[:args].map { |arg_node| Eval.process_node(arg_node) }

        return fn.call(args)
      end

      raise UnexpectedNodeError, node.inspect
    end
  end

  class Parser
    class UnexpectedTokenError < StandardError; end

    CALL_EXPRESSION = 'CallExpression'
    VARIABLE_DEFINITION = 'VariableDefinition'
    NAME_LITERAL = 'NameLiteral'
    NUMBER_LITERAL = 'NumberLiteral'

    def self.parse(tokens)
      current = 0
      parse_operation = lambda do
        token = tokens[current]

        case token[:kind]
        when Tokenizer::LPAREN
          # Advance to keyword
          current += 1
          token = tokens[current]

          if token[:value] == 'defvar'
            # Advance to variable name
            current += 1

            node = {
              kind: VARIABLE_DEFINITION,
              name: parse_operation.call,
              value: parse_operation.call,
            }

            # Skip RPAREN
            current += 1

            return node
          else
            node = {
              kind: CALL_EXPRESSION,
              name: token[:value],
              args: [],
            }

            # Advance to arguments
            current += 1
            token = tokens[current]

            # Continue until RPAREN
            while token[:kind] != Tokenizer::RPAREN do
              node[:args].push(parse_operation.call)
              token = tokens[current]
            end

            # Skip RPAREN
            current += 1

            return node
          end

          raise UnexpectedTokenError, 'Cannot detect kind of a node', token.inspect
        when Tokenizer::NAME
          node = {
            kind: NAME_LITERAL,
            value: token[:value],
          }

          current += 1
          return node
        when Tokenizer::NUMBER
          node = {
            kind: NUMBER_LITERAL,
            value: token[:value],
          }

          current += 1
          return node
        end

        raise UnexpectedTokenError, 'Token of an unexpected kind', token.inspect
      end

      ast = []
      while current < tokens.size do
        ast.push(parse_operation.call)
      end

      ast
    end
  end

  class Tokenizer
    class UnexpectedCharacterError < StandardError; end

    LPAREN = '('
    RPAREN = ')'
    NUMBER = 'Number'
    NAME = 'Name'

    def self.tokenize(program)
      tokens = []
      pos = 0
      while pos < program.size
        code = program[pos].ord

        case
        # LPAREN
        when code == 40
          tokens.push(kind: LPAREN, value: program[pos])
          pos += 1
          next
        # RPAREN
        when code == 41
          tokens.push(kind: RPAREN, value: program[pos])
          pos += 1
          next
        # NAME
        when self.is_name?(code)
          value = ''
          # NOTE: using modified `pos`
          while self.is_name?(program[pos].ord)
            value.concat(program[pos])
            pos += 1
          end
          tokens.push(kind: NAME, value: value)

          next
        # NUMBER
        when self.is_number?(code)
          value = ''
          # NOTE: using modified `pos`
          while self.is_number?(program[pos].ord)
            value.concat(program[pos])
            pos += 1
          end
          tokens.push(kind: NUMBER, value: value.to_i)

          next
        # space, new line
        when code == 32 || code == 10
          pos += 1
          next
        # carriage return
        when code == 13
          pos += 2
          next
        end

        raise UnexpectedCharacterError
      end

      tokens
    end

    private

    def self.is_name?(code)
      (code >= 65 && code <= 90) || code == 95 || (code >= 97 && code <= 122)
    end

    def self.is_number?(code)
      code == 45 || (code >= 48 && code <= 57)
    end
  end
end
