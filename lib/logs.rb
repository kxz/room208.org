class IRCLog < ::Nanoc::Core::Filter
  identifier :irclog

  def run(content, params={})
    interstat(content)
  end
end

def parse_log_time(line)
  line.match(/^@time=(\S+)/) { |m| Time.strptime(m[1], '%FT%T.%L%z') }
end

def set_log_attributes(item)
  lines = item.raw_content.lines
  item[:start_time] = parse_log_time(lines.first)
  item[:end_time] = parse_log_time(lines.last)
  item[:duration] = item[:end_time] - item[:start_time]
  item[:line_count] = lines.length
end
