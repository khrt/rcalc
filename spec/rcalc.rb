$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rcalc'

describe 'Eval' do
  it 'should evaluate a simple program' do
    res = Rcalc::Eval.interpret(Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(add 2 2)')))
    expect(res).to eq('4')
  end

  it 'should evaluate a nested program' do
    res = Rcalc::Eval.interpret(Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(add 2 (subtract 4 2))')))
    expect(res).to eq('4')
  end

  it 'should evaluate a progam with a variable declaration' do
    res = Rcalc::Eval.interpret(Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(defvar x 1) (add x 1)')))
    expect(res).to eq('2')
  end

  it 'should raise UnexpectedNodeError exception' do
    skip
  end

  it 'should raise UnknownCallExpressionError exception' do
    expect {
      Rcalc::Eval.interpret(Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(multiply 2 2)')))
    }.to raise_error(Rcalc::Eval::UnexpectedCallExpressionError)
  end
end

describe 'Parser' do
  it 'should parse a simple program' do
    ast = Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(add 2 2)'))
    expect(ast).to eq([
      {
        kind: 'CallExpression',
        name: 'add',
        args: [
          {
            kind: 'NumberLiteral',
            value: 2,
          },
          {
            kind: 'NumberLiteral',
            value: 2,
          },
        ],
      },
    ]);
  end

  it 'should tokenize a nested program' do
    ast = Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(add 2 (subtract 4 2))'))
    expect(ast).to eq([
      {
        kind: 'CallExpression',
        name: 'add',
        args: [
          {
            kind: 'NumberLiteral',
            value: 2,
          },
          {
            kind: 'CallExpression',
            name: 'subtract',
            args: [
              {
                kind: 'NumberLiteral',
                value: 4,
              },
              {
                kind: 'NumberLiteral',
                value: 2,
              },
            ],
          },
        ],
      },
    ]);
  end

  it 'should tokenize a progam with a variable declaration' do
    ast = Rcalc::Parser.parse(Rcalc::Tokenizer.tokenize('(defvar x 1) (add x 1)'))
    expect(ast).to eq([
      {
        kind: 'VariableDefinition',
        name: {
          kind: 'NameLiteral',
          value: 'x',
        },
        value: {
          kind: 'NumberLiteral',
          value: 1,
        },
      },
      {
        kind: 'CallExpression',
        name: 'add',
        args: [
          {
            kind: 'NameLiteral',
            value: 'x',
          },
          {
            kind: 'NumberLiteral',
            value: 1,
          },
        ],
      },
    ])
  end

  it 'should raise UnexpectedTokenError exception' do
    skip
  end
end

describe 'Tokenizer' do
  it 'should tokinze simple program' do
    expect(Rcalc::Tokenizer.tokenize('(add 2 2)')).to eq ([
      { kind: '(', value: '(' },
      { kind: 'Name', value: 'add' },
      { kind: 'Number', value: 2 },
      { kind: 'Number', value: 2 },
      { kind: ')', value: ')' },
    ])
  end

  it 'should tokenize a nested program' do
    expect(Rcalc::Tokenizer.tokenize('(add (subtract 4 2) 2)')).to eq ([
      { kind: '(', value: '(' },
      { kind: 'Name', value: 'add' },
      { kind: '(', value: '(' },
      { kind: 'Name', value: 'subtract' },
      { kind: 'Number', value: 4 },
      { kind: 'Number', value: 2 },
      { kind: ')', value: ')' },
      { kind: 'Number', value: 2 },
      { kind: ')', value: ')' },
    ])
  end

  it 'should tokenize a progam with a variable declaration' do
    expect(Rcalc::Tokenizer.tokenize('(defvar x 1) (add x 2)')).to eq([
      { kind: '(', value: '(' },
      { kind: 'Name', value: 'defvar' },
      { kind: 'Name', value: 'x' },
      { kind: 'Number', value: 1 },
      { kind: ')', value: ')' },
      { kind: '(', value: '(' },
      { kind: 'Name', value: 'add' },
      { kind: 'Name', value: 'x' },
      { kind: 'Number', value: 2 },
      { kind: ')', value: ')' },
    ])
  end

  it 'should raise UnexpectedCharacterError exception' do
    expect {
      Rcalc::Tokenizer.tokenize('!')
    }.to raise_error(Rcalc::Tokenizer::UnexpectedCharacterError)
  end
end
