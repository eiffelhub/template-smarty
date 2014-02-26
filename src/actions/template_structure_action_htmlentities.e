note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2013-12-17 11:07:46 +0100 (mar., 17 déc. 2013) $"
	revision    : "$Revision: 93741 $"

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
			item_output := (create {HTML_ENCODER}).encoded_string (foreach_iteration_string (inside_text, False))
			set_forced_output (item_output)
		end

note
	copyright: "2011-2013, Jocelyn Fiat, and Eiffel Software"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
