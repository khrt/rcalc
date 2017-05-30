# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'RCalc'
  spec.version       = '0.1'
  spec.authors       = ['Artur Khabibullin']
  spec.email         = ['rtkh@ya.ru']

  spec.summary       = 'A Lispy Calculator Interpreter'
  spec.description   = 'An interpreter for a simple Lips-like calculator language'
  spec.homepage      = 'https://github.com/khrt/rcalc'

  spec.files         = ['spec/rcalc.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
