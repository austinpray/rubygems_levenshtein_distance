#!/usr/bin/env ruby

module Before
  def min3(a, b, c) # :nodoc:
    if a < b && a < c
      a
    elsif b < c
      b
    else
      c
    end
  end

  # This code is based directly on the Text gem implementation
  # Returns a value representing the "cost" of transforming str1 into str2
  def levenshtein_distance(str1, str2)
    s = str1
    t = str2
    n = s.length
    m = t.length

    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    str1.each_char.each_with_index do |char1,i|
      e = i + 1

      str2.each_char.each_with_index do |char2,j|
        cost = (char1 == char2) ? 0 : 1
        x = min3(
          d[j + 1] + 1, # insertion
          e + 1,      # deletion
          d[j] + cost # substitution
        )
        d[j] = e
        e = x
      end

      d[m] = x
    end

    return x
  end

  module_function :min3, :levenshtein_distance
end

module After
  # Returns a value representing the "cost" of transforming str1 into str2
  def levenshtein_distance(str1, str2)
    DidYouMean::Levenshtein.distance(str1, str2)
  end

  module_function :levenshtein_distance
end

module AfterRescue
  # Returns a value representing the "cost" of transforming str1 into str2
  def levenshtein_distance(str1, str2)
    begin
      require 'did_you_mean/levenshtein'
      DidYouMean::Levenshtein.distance(str1, str2)
    rescue LoadError
      Before.levenshtein_distance(str1, str2)
    end
  end

  module_function :levenshtein_distance
end


module AfterPatch
  # Returns a value representing the "cost" of transforming str1 into str2
  def levenshtein_distance(str1, str2)
    raise 'should be overridden'
  end

  module_function :levenshtein_distance
end

begin
  require 'did_you_mean/levenshtein'
  module AfterPatch
    # Returns a value representing the "cost" of transforming str1 into str2
    def levenshtein_distance(str1, str2)
      DidYouMean::Levenshtein.distance(str1, str2)
    end
    module_function :levenshtein_distance
  end
rescue LoadError; end


if $PROGRAM_NAME == __FILE__
  require 'benchmark/ips'

  puts "# Single Insertion"
  puts
  str1 = "helo world"
  str2 = "hello world"

  Benchmark.ips do |x|
    x.report("Before") do
      Before.levenshtein_distance str1, str2
    end
    x.report("After") do
      After.levenshtein_distance str1, str2
    end
  end

  puts "# Complex"
  puts
  str1 = "algorithm"
  str2 = "altruistic"

  Benchmark.ips do |x|
    x.report("Before") do
      Before.levenshtein_distance str1, str2
    end
    x.report("After") do
      After.levenshtein_distance str1, str2
    end
    x.report("AfterRescue") do
      AfterRescue.levenshtein_distance str1, str2
    end
    x.report("AfterPatch") do
      AfterPatch.levenshtein_distance str1, str2
    end
  end


end
