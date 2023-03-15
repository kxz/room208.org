def parse_log_time(line)
  Time.strptime("#{line[1...21]} +0000", '%d-%b-%Y %H:%M:%S %z')
end

def set_log_attributes(item)
  lines = item.raw_content.lines
  item[:start_time] = parse_log_time(lines.first)
  item[:end_time] = parse_log_time(lines.last)
  item[:duration] = item[:end_time] - item[:start_time]
  item[:line_count] = lines.length
end
