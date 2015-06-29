#!/usr/bin/env ruby -w

class WordCount
  def initialize(stream, string, buffer_size_limit=(1024 ** 2))
    @stream = stream
    raise ArgumentError, "empty search string" if string.empty?
    @string = string
    @buffer_size_limit = buffer_size_limit
    @buffer = ""
  end

  def count_occurrences
    occurrences = 0
    while ensure_buffer
      ## Just optimistically look for the string in the buffer
      if found_pos = index(@string)
        skip_to(found_pos + @string.size)
        occurrences += 1
      else
        # Throw away the part of the buffer we know can't contain part of the string
        first_char_pos = first_possible_starting_pos
        @buffer = first_char_pos ? skip_to(first_char_pos) : ""
      end
    end
    occurrences
  end

  private

  def skip_to(pos)
    @buffer = @buffer.slice(pos..-1)
  end

  def index(str, offset=0)
    @buffer.index(str, offset)
  end

  def first_possible_starting_pos
    ## Searching for foo
    ##  0 1 2 3 4 5 6 7 8 9 | STREAM
    ##  x x x x x x x x f o | o
    index(@string[0], @buffer.size - @string.size + 1)
  end

  def ensure_buffer
    buffer_smaller_than_string? ? read_more_into_buffer : true
  end

  def buffer_smaller_than_string?
    @buffer.empty? || (@buffer.size < @string.size)
  end

  def read_more_into_buffer
    wanted = @buffer_size_limit - @buffer.size
    next_chunk = @stream.read(wanted)
    return false if (next_chunk.nil? || next_chunk.empty?)
    @buffer += next_chunk
  end
end

if __FILE__ == $0
  puts WordCount.new(STDIN, ARGV.first).count_occurrences
end
