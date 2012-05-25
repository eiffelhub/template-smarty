note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2010-06-11 09:18:42 +0200 (Fri, 11 Jun 2010) $"
	revision    : "$Revision: 401 $"

class
	TEMPLATE_STRUCTURE_ACTION_HTMLENTITIES

inherit
	TEMPLATE_STRUCTURE_ACTION
		redefine
			process
		end

create {TEMPLATE_STRUCTURE_ACTION_FACTORY}
	make

feature -- Output

	process
		do
			Precursor
			process_htmlentities
		end

feature {NONE} -- Implementation

	process_htmlentities
		local
			item_output: STRING
		do
			item_output := foreach_iteration_string (inside_text, False)
			item_output.replace_substring_all ("&", "&amp;")
			item_output.replace_substring_all ("<", "&lt;")
			item_output.replace_substring_all (">", "&gt;")
			set_forced_output (item_output)
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
