# frozen_string_literal: true

require 'bolt/pal'

module Bolt
  class Outputter
    class Rainbow < Bolt::Outputter::Human
      def initialize(color, verbose, trace, stream = $stdout)
        begin
          require 'paint'
          if Bolt::Util.windows?
            # the Paint gem thinks that windows does not support ansi colors
            # but windows 10 or later does
            # we can display colors if we force mode to TRUE_COLOR
            Paint.mode = 0xFFFFFF
          end
        rescue LoadError
          raise "The 'paint' gem is required to use the rainbow outputter."
        end
        super
        @line_color = 0
        @color = 0
        @state = :normal
      end

      # The algorithm is from lolcat (https://github.com/busyloop/lolcat)
      # lolcat is released with WTFPL
      def rainbow
        red = Math.sin(0.3 * @color + 0) * 127 + 128
        green = Math.sin(0.3 * @color + 2 * Math::PI / 3) * 127 + 128
        blue  = Math.sin(0.3 * @color + 4 * Math::PI / 3) * 127 + 128
        @color += 1 / 8.0
        format("%<red>02X%<green>02X%<blue>02X", red: red, green: green, blue: blue)
      end

      def colorize(color, string)
        if @color && @stream.isatty
          if %i[green rainbow].include?(color)
            a = string.chars.map do |c|
              case @state
              when :normal
                if c == "\e"
                  @state = :ansi
                elsif c == "\n"
                  @line_color += 1
                  @color = @line_color
                  c
                else
                  Paint[c, rainbow]
                end
              when :ansi
                @state = :normal if c == 'm'
              end
            end
            a.join('')
          else
            "\033[#{COLORS[color]}m#{string}\033[0m"
          end
        else
          string
        end
      end

      def print_summary(results, elapsed_time = nil)
        ok_set = results.ok_set
        unless ok_set.empty?
          @stream.puts colorize(:rainbow, format('Successful on %<size>d target%<plural>s: %<names>s',
                                                 size: ok_set.size,
                                                 plural: ok_set.size == 1 ? '' : 's',
                                                 names: ok_set.targets.map(&:safe_name).join(',')))
        end

        error_set = results.error_set
        unless error_set.empty?
          @stream.puts colorize(:red,
                                format('Failed on %<size>d target%<plural>s: %<names>s',
                                       size: error_set.size,
                                       plural: error_set.size == 1 ? '' : 's',
                                       names: error_set.targets.map(&:safe_name).join(',')))
        end

        total_msg = format('Ran on %<size>d target%<plural>s',
                           size: results.size,
                           plural: results.size == 1 ? '' : 's')
        total_msg << " in #{duration_to_string(elapsed_time)}" unless elapsed_time.nil?
        @stream.puts colorize(:rainbow, total_msg)
      end
    end
  end
end
