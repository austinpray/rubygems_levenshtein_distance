#!/usr/bin/env ruby

# gems from rails
gems = [
  'rake',
  'capybara',
  'selenium-webdriver',
  'rack-cache',
  'sass-rails',
  'turbolinks',
  'webpacker',
  'bcrypt',
  'uglifier',
  'json',
  'rubocop',
  'rubocop-performance',
  'rubocop-rails',
  'sdoc',
  'redcarpet',
  'w3c_validators',
  'kindlerb',
  'rouge',
  'dalli',
  'listen',
  'libxml-ruby',
  'connection_pool',
  'rexml',
  'bootsnap',
  'resque',
  'resque-scheduler',
  'sidekiq',
  'sucker_punch',
  'delayed_job',
  'queue_classic',
  'sneakers',
  'que',
  'backburner',
  'delayed_job_active_record',
  'sequel',
  'puma',
  'hiredis',
  'redis',
  'redis-namespace',
  'websocket-client-simple',
  'blade',
  'blade-sauce_labs_plugin',
  'sprockets-export',
  'aws-sdk-s3',
  'google-cloud-storage',
  'azure-storage-blob',
  'image_processing',
  'aws-sdk-sns',
  'webmock',
  'qunit-selenium',
  'webdrivers',
  'minitest-bisect',
  'minitest-retry',
  'minitest-reporters',
  'stackprof',
  'byebug',
  'benchmark-ips',
  'nokogiri',
  'racc',
  'sqlite3',
  'pg',
  'mysql2',
  'activerecord-jdbcsqlite3-adapter',
  'activerecord-jdbcmysql-adapter',
  'activerecord-jdbcpostgresql-adapter',
  'activerecord-jdbcsqlite3-adapter',
  'activerecord-jdbcmysql-adapter',
  'activerecord-jdbcpostgresql-adapter',
  'psych',
  'ruby-oci8',
  'activerecord-oracle_enhanced-adapter',
  'tzinfo-data',
  'wdm',
].uniq

class SimilarityDetector
  SimilarityScore = Struct.new(:string, :distance)

  # initialize with an array of words to be matched against
  def initialize(corpus)
    @corpus = corpus
  end

  # return an array of words similar to 'word' from the corpus
  def similar_words(word, limit = 3)
    words_by_similarity = @corpus.map {|w| SimilarityScore.new(w, levenshtein_distance(word, w)) }
    words_by_similarity.select {|s| s.distance <= limit }.sort_by(&:distance).map(&:string)
  end

  # return the result of 'similar_words', concatenated into a list
  # (eg "a, b, or c")
  def similar_word_list(word, limit = 3)
    words = similar_words(word, limit)
    if words.length == 1
      words[0]
    elsif words.length > 1
      [words[0..-2].join(", "), words[-1]].join(" or ")
    end
  end

  protected

  # https://www.informit.com/articles/article.aspx?p=683059&seqNum=36
  def levenshtein_distance(this, that, ins = 2, del = 2, sub = 1)
    # ins, del, sub are weighted costs
    return nil if this.nil?
    return nil if that.nil?
    dm = [] # distance matrix

    # Initialize first row values
    dm[0] = (0..this.length).collect {|i| i * ins }
    fill = [0] * (this.length - 1)

    # Initialize first column values
    (1..that.length).each do |i|
      dm[i] = [i * del, fill.flatten]
    end

    # populate matrix
    (1..that.length).each do |i|
      (1..this.length).each do |j|
        # critical comparison
        dm[i][j] = [
          dm[i - 1][j - 1] + (this[j - 1] == that[i - 1] ? 0 : sub),
          dm[i][j - 1] + ins,
          dm[i - 1][j] + del,
        ].min
      end
    end

    # The last value in matrix is the Levenshtein distance between the strings
    dm[that.length][this.length]
  end
end

if $PROGRAM_NAME == __FILE__
  require 'benchmark/ips'

  before = SimilarityDetector.new(gems)

  after = DidYouMean::SpellChecker.new(dictionary: gems)

  Benchmark.ips do |x|
    x.report("Before") do
      before.similar_word_list('activerecord-jdbcslite3-adapter')
    end
    x.report("After") do
      after.correct('activerecord-jdbcslite3-adapter')
    end
  end

end
