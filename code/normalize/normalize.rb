#!/usr/bin/env ruby


tokens = {
    "!" : "<exclamation>",
    "?" : "<question>",
    "." : "<eosentence",
	",": " , ", # Make sure to split commas from words
	"'": " '", # Separate contractions"
}

def normalize_text(raw)
    tokens.each do |char, replacement|
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

def normalize_file(file)
    lines = season.split("\n") - [""]

    exposition = []
    contents = File.read(file).split("\n").collect do |line|
        next if line.size == 0
        if line_type(line) == :character_line
            parse_character_line(line)
        else
            parse_exposition(line)
        end
    end
    contents << "<eoepisode>"
	new_file_name = file.gsub("raw","normalized")
	f = File.new(new_file_name, "w")
	f << contents.compact.join("\n")
end

def line_type(line)
    # e.g. exposition: 2 INT. VILLAGE POST OFFICE. DAWN.
    if line =~ /[0-9]([\sA-Z\.]*?)$/
        return :exposition
    else
        return :character
    end
end

def parse_character_line(text)
    # e.g.
    # POSTMASTER: You do it
    # POSTMASTER (CONT’D): I’ll take it up there now.

    name, line = text.split(":")

    name.gsub!/\(.*?\)/,"").gsub!(" ","_")
	
	line = parse_text(line)
      
	"<boname>#{name}<eoname>#{line}"
end

def parse_exposition(title, line)


end
