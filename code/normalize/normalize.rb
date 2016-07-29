#!/usr/bin/env ruby


$tokens = {
    "!" => "<exclamation>",
    "?" => "<question>",
    "." => "<eosentence",
	"," => " , ", # Make sure to split commas from words
	"'" => " '", # Separate contractions"
	"*" => "<sarcasm>"
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
	contents << "<boseason>"

	File.read(file).split("\n").each do |line|
        next if line.size == 0
		this_line_type = line_type(line)
		puts "line=#{line}"
		puts "line_type=#{this_line_type}"
        if this_line_type != :multi_exposition
			if exposition_lines.size > 0
				contents << parse_exposition(exposition_lines)
				exposition_lines = []
			end
			if this_line_type == :character_line
            	contents << parse_character_line(line)
			else
				contents << parse_single_exposition(line)
			end
        end
    end
    contents << "<eoseason>"
	new_file_name = file.gsub("raw","normalized")
	f = File.new(new_file_name, "w")
	f << contents.compact.join("\n")
	puts contents
end

def line_type(line)
    # e.g. exposition: 2 INT. VILLAGE POST OFFICE. DAWN.
    if line =~ /[0-9]([\sA-Z\.]*?)$/
        return :multi_exposition
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
	
	line = parse_text(line)
      
	"<boname>#{name}<eoname>#{line}"
end

def parse_single_exposition(line)
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

	""
end

def parse_exposition(lines)
	content = "<boexposition>"
	content << parse_text(lines.first.gsub(/^[0-9]/, ""))

	lines[1..-1].each do |line|
		content << parse_text(line)
	end

	content << "<eoexposition>"
end


normalize
