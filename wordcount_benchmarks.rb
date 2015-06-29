#!/usr/bin/env ruby -w

require_relative 'wordcount'
require 'benchmark'
require 'ruby-prof'

module Measurements
  def benchmark(meth)
    times = Benchmark.measure(&method(meth))
    runafters
    puts "Times:     #{times}"
  end

  def profile(meth)
    result = RubyProf.profile do
      send(meth)
    end
    runafters
    printer = RubyProf::CallStackPrinter.new(result)
    fname = "/tmp/profile.html"
    File.open(fname, 'w') do |f|
      printer.print(f)
    end
    system("open '#{fname}'")
  end

  def after(&block)
    (@after ||= []) << block
  end

  private

  def runafters
    @after ||= []
    @after.each(&:call)
  end
end



class WordCountBenchmark
  include Measurements

  def run
    puts WordCount.new(File.open('/usr/share/dict/words', 'r'), "the").count_occurrences
  end

end


WordCountBenchmark.new.profile(:run)
