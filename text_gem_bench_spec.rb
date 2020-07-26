require 'rspec'
require_relative 'text_gem_bench'

shared_examples 'an edit distance function' do

  it 'calculates the minimum edit distance between two strings' do
    expect(subject.call('algorithm', 'altruistic')).to eq(6)
    expect(subject.call('sunday', 'saturday')).to eq(3)
    expect(subject.call('ABC', 'ABB')).to eq(1)
  end

  example 'noop' do
    expect(subject.call('', '')).to eq(0)
    expect(subject.call('AAA', 'AAA')).to eq(0)
  end

  example 'pure insertions' do
    expect(subject.call('', 'ABB')).to eq(3)
  end

  example 'pure deletions' do
    expect(subject.call('ABC', '')).to eq(3)
  end

  example 'pure substitutions' do
    expect(subject.call(('A' * 10), ('B' * 10))).to eq(10)
  end
end

RSpec.describe Before do
  it_behaves_like 'an edit distance function' do
    subject { Before.method(:levenshtein_distance) }
  end
end
RSpec.describe After do
  it_behaves_like 'an edit distance function' do
    subject { After.method(:levenshtein_distance) }
  end
end
