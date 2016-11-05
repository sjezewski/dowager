#!/usr/bin/env ruby


$tokens = {
    "!" => "<exclamation>",
    "?" => "<question>",
    "." => "<eosentence>",
	"," => " , ", # Make sure to split commas from words
	"'" => " '", # Separate contractions"
	"*" => "<sarcasm>" # Actually footnotes ... but fair proxy for sarcasm!
}

def parse_text(raw)
    $tokens.each do |char, replacement|
        raw.gsub!(char, replacement)
    end
    raw
end

def normalize
    Dir.glob("data/raw/*.txt").each do |file|
		puts "Normalizing #{file}"
		normalize_file(file)
	end

end

# One file is a season
def normalize_file(file)

    exposition_lines = []
    contents = []
	contents << "<boseason>" # Missing start token, so add it manually

	File.read(file).split("\n").each do |line|
        next if line.size == 0

		token = parse_structured_exposition(line)

		unless token.nil?
			contents << token
			next
		end

		this_line_type = line_type(line)
		puts "line=#{line}"
		puts "line_type=#{this_line_type}"
        if this_line_type == :multi_exposition
			exposition_lines << line
		else
			if exposition_lines.size > 0
				contents << parse_exposition(exposition_lines)
				exposition_lines = []
			end
            case this_line_type
                when :single_exposition
                    contents << parse_single_exposition(line)
                else
                    contents << parse_character_line(line)
            end
		end
    end
    contents << "<eoseason>"
	new_file_name = file.gsub("raw","normalized")
	f = File.new(new_file_name, "w")
	f << fix_bad_characters(contents.compact.join("\n"))
end

def fix_bad_characters(s)
	# E.g. I get:
	# can't encode character u'\u2019' (or 2018) these are the special symbols for left and right single quote
	# in the generate job sometimes, so I need to fix them here
	s.gsub(/[\u2014|\u2018|\u2019|\u2020|\u2026]/, "")
end

def line_type(line)
    # e.g. exposition: 2 INT. VILLAGE POST OFFICE. DAWN.
    if line =~ /[0-9]([\sA-Z\.]*?)$/
        return :multi_exposition
	elsif line =~ /^(END|EPISODE|ACT|SCENE|SEASON)$/
		return :structured_exposition
	elsif line =~ /[A-Z\s]$/
		return :single_exposition
	elsif line =~ /^[A-Z\s\(\)\.]*?\:/
        return :character_line
	else
        return :multi_exposition
    end
end

def parse_character_line(text)
    # e.g.
    # POSTMASTER: You do it
    # POSTMASTER (CONT’D): I’ll take it up there now.

    name, line = text.split(":")
	puts "text=> name(#{name}), line(#{line})"

    name.gsub!(" ","_")
	
    puts "parsing char line: #{line}"
	line = parse_text(line)
      
	"<boname>#{name}<eoname>#{line}"
end

def parse_structured_exposition(line)
	#e.g.
	# EPISODE TWO
	# END OF EPISODE ONE
	# END OF ACT ONE

	if line =~ /^(END OF) (.*?)/
		type = $2.downcase.gsub(" ","_")
		return "<eo#{type}>"
	elsif line =~ /^([A-Z\s]*?)$/
		type = $1.downcase.gsub(" ", "_")
		return "<bo#{type}>"
	end

	nil
end

def parse_single_exposition(line)
	#e.g.
    # SCENE—NO DIALOGUE OF THOMAS WALKING THROUGH THE VILLAGE
    content = line.gsub("SCENE", "")
    "<boexposition>#{content}<eoexposition>"
end

def parse_exposition(lines)
	content = "<boexposition>"
    puts "parsing expo lines: #{lines}"
	content << parse_text(lines.first.gsub(/^[0-9]/, ""))

	lines[1..-1].each do |line|
		content << parse_text(line)
	end

	content << "<eoexposition>"
end


normalize

prefix = "data/normalized"
%x`cat #{prefix}/season*.txt > #{prefix}/all.txt`

all = File.read("#{prefix}/all.txt")

token = "<boname>"
lines = all.split token

# 80% to training
# 10% to test
# 10% to valid

test = lines.size / 10
valid = test * 2

File.open("#{prefix}/ptb.test.txt", "w") << lines[0..(test-1)].join(token)
v = File.open("#{prefix}/ptb.valid.txt", "w")
v << token
v << lines[test..(valid-1)].join(token)
t = File.open("#{prefix}/ptb.train.txt", "w")
t << token
t << lines[valid..-1].join(token)


