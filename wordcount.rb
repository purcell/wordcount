#!/usr/bin/env ruby -w

class Buffer
  def initialize(buffer_size_limit, &read_chunk)
    @read_chunk = read_chunk
    @buffer_size_limit = buffer_size_limit
    @buffer = ""
  end

  def empty?
    @buffer.empty?
  end

  def index(str, offset=0)
    @buffer.index(str, offset)
  end

  def skip_to(pos)
    @buffer = @buffer.slice(pos..-1)
  end

  def skip_to_end
    @buffer = ""
  end

  def ensure_length(len)
    if @buffer.empty? || (@buffer.size < len)
      wanted = @buffer_size_limit - @buffer.size
      next_chunk = @read_chunk.call(wanted)
      return false if (next_chunk.nil? || next_chunk.empty?)
      @buffer += next_chunk
    else
      true
    end
  end

  def size
    @buffer.size
  end
end

class WordCount
  def initialize(stream, string, buffer_size_limit=(1024 ** 2))
    raise ArgumentError, "empty search string" if string.empty?
    @string = string
    @buffer = Buffer.new(buffer_size_limit, &stream.method(:read))
  end

  def count_occurrences
    occurrences = 0
    while @buffer.ensure_length(@string.size)
      ## Just optimistically look for the string in the buffer
      if found_pos = @buffer.index(@string)
        @buffer.skip_to(found_pos + @string.size)
        occurrences += 1
      elsif first_char_pos = first_possible_starting_position
        # Throw away the part of the buffer we know can't contain part of the string
        @buffer.skip_to(first_char_pos)
      else
        @buffer.skip_to_end
      end
    end
    occurrences
  end

  private

  def first_possible_starting_position
    ## Searching for "foo", which we know isn't fully in the buffer
    ##  0 1 2 3 4 5 6 7 8 9 | STREAM
    ##  x x x x x x x x f o | o
    @buffer.index(@string[0], @buffer.size - @string.size + 1)
  end
end

if __FILE__ == $0
  puts WordCount.new(STDIN, ARGV.first).count_occurrences
end
