#!/usr/bin/env ruby

require 'erb'
require 'rinku'
require 'time'
require 'zlib'

def colorhash(str)
  '#%03x' % (Zlib.adler32(str) & 0x777)
end

MIRC_COLORS = [
  'white', 'black', 'navy', 'green', 'red', 'maroon', 'purple', 'olive',
  'yellow', 'lime', 'teal', 'cyan', 'royalblue', 'pink', 'gray', 'lightgray',
]

def mirc_color(numeric)
  MIRC_COLORS[numeric.to_i % MIRC_COLORS.length]
end

FORMATTING_BOUNDARIES =
  /(\x02|\x03(?:[0-9]{1,2}(?:,[0-9]{1,2})?)?|\x0f|\x16|\x1f)/

def ircformat(str)
  html = ''
  bold = italic = underline = false
  fg = bg = nil

  str.split(FORMATTING_BOUNDARIES) do |token|
    case token
    when ""
      next
    when "\x02"
      bold = !bold
    when /^\x03/
      (newfg, newbg) = $'.split(',')
      if newfg
        fg = newfg
        if newbg
          bg = newbg
        end
      else
        fg = bg = nil
      end
    when "\x0f"
      bold = italic = underline = false
      fg = bg = nil
    when "\x16"
      italic = !italic
    when "\x1f"
      underline = !underline
    else
      style = [
        ("background-color: #{mirc_color(bg)}" if bg),
        ("color: #{mirc_color(fg)}" if fg),
        ('font-style: italic' if italic),
        ('font-weight: bold' if bold),
        ('text-decoration: underline' if underline),
      ].compact
      text = Rinku.auto_link(ERB::Escape.html_escape(token), mode=:urls)
      html << if style.empty?
        text
      else
        %{<span style="#{style.join('; ')}">#{text}</span>}
      end
    end
  end

  html
end

def interstat(log)
  out = "<ol>\n"

  log.each_line("\r\n", chomp: true).with_index(1) do |line, index|
    id = "L#{index}"
    out << <<~EOF.delete("\n")
      <li id="#{id}">
      <a class="timestamp" title="permalink to this message" href="##{id}">
    EOF

    unless line =~ /^@time=(\S+) /
      raise "Missing @time tag on line #{index}: #{line}"
    end
    time = Time.strptime($1, '%FT%T.%L%z')
    out << <<~EOF.delete("\n")
      <time datetime="#{time.strftime('%FT%TZ')}">
      #{time.strftime('%H:%M')}
      </time>
      </a>
    EOF
    out << ' '

    out << case $'
    when /^:(?<source>\S+) PRIVMSG (?<target>\S+) :\x01ACTION /
      <<~EOF.delete("\n")
        <span class="actor">»
         <b class="nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </b>
        </span>
         <span class="content">#{ircformat($'.chomp("\x01"))}</span>
      EOF
    when /^:(?<source>\S+) PRIVMSG (?<target>\S+) :/
      <<~EOF.delete("\n")
        <span class="actor">&lt;
        <b class="nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </b>
        &gt;</span>
         <span class="content">#{ircformat($')}</span>
      EOF
    when /^:(?<source>\S+) NOTICE (?<target>\S+) :/
      <<~EOF.delete("\n")
        <span class="actor">–
        <b class="nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </b>
        –</span>
         <span class="content">#{ircformat($')}</span>
      EOF
    when /^:(?<source>\S+) NICK (?<nickname>\S+)$/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">is now known as
         <span class="nick" style="color: #{colorhash($~[:nickname])}">
        #{$~[:nickname]}
        </span>
        </span>
      EOF
    when /^:(?<source>\S+) JOIN (?<channel>\S+)$/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">has joined #{$~[:channel]}</span>
      EOF
    when /^:(?<source>\S+) PART (?<channel>\S+)$/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">has left #{$~[:channel]}</span>
      EOF
    when /^:(?<source>\S+) QUIT(?: :)?/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">
        has quit IRC
        #{" (#{ircformat($')})" unless $'.empty?}
        </span>
      EOF
    when /^:(?<source>\S+) KICK (?<channel>\S+) (?<user>\S+)(?: :)/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:user])}">
        #{$~[:user]}
        </span>
         <span class="misc">
        was kicked by
         <span class="nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
        #{" (#{ircformat($')})" unless $'.empty?}
        </span>
      EOF
    when /^:(?<source>\S+) TOPIC (?<channel>\S+) :/
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">changes topic to #{ircformat($')}</span>
      EOF
    when /^:(?<source>\S+) MODE (?<channel>\S+) /
      <<~EOF.delete("\n")
        <span class="actor nick" style="color: #{colorhash($~[:source])}">
        #{$~[:source]}
        </span>
         <span class="misc">sets mode: #{$'}</span>
      EOF
    else
      raise "Could not parse line #{index}: #{line}"
    end

    out << "\n</li>\n"
  end

  out << "</ol>\n"
  out
end

if __FILE__ == $0
  print interstat(ARGF.read)
end
