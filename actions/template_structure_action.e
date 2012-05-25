note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEMPLATE_STRUCTURE_ACTION

inherit
	TEMPLATE_STRUCTURE_ITEM
		rename
			name as action_name,
			set_name as set_action_name
		redefine
			action_name, set_action_name,
			make, get_output
		end

create {TEMPLATE_STRUCTURE_ACTION_FACTORY}
	make

feature {NONE} -- Initialization

	make
		do
			Precursor
			create parameters.make (3)
		end

feature {TEMPLATE_TEXT} -- Type

	is_literal_action: BOOLEAN
		do
			Result := False
		end

feature -- Output

	get_output
		do
			Precursor
--			if output = Void then
--				if is_foreach_action then
--					output := "{!! Action[" + action_name + "] !!}"
--				end
--			end
		end

feature -- Access

	action_name: STRING

	parameters: DS_HASH_TABLE [STRING, STRING]

feature -- Change

	set_action_name (v: like action_name)
		do
			action_name := v
		end

	add_parameter (pv, pn: STRING)
			-- add param_value, param_name
		do
			parameters.put (pv, pn)
		end

feature {NONE} -- Implementation

	inside_text: STRING
		do
			Result := template_context.current_template_string.substring (end_index + 1, closing_start_index - 1)
		end

	foreach_iteration_string (on_text: STRING; reset_offset: BOOLEAN): STRING
		require
			on_text /= Void
		local
			s1, s2: INTEGER
			t: TEMPLATE_STRUCTURE_ITEM
			ta: TEMPLATE_STRUCTURE_ACTION
			val: STRING
			soffset: INTEGER
			item_output: STRING
		do
			from -- Loop Iteration
				items.start
				if not reset_offset then
					soffset := 0 - end_index
				end
				item_output := on_text.twin
			until
				items.after
			loop
				t := items.item_for_iteration
				s1 := t.start_index
				s2 := t.end_index

				t.process
				t.get_output
				val := t.output
				if val = Void then
					val := ""
				end

				ta ?= t
				if ta /= Void then
					if t.has_closing_item then
						s2 := t.closing_end_index
					end
					item_output.replace_substring (val, soffset + s1, soffset + s2)
					soffset := soffset + val.count - 1 - (s2 - s1)
				else
					item_output.replace_substring (val, soffset + s1, soffset + s2)
					soffset := soffset + val.count - 1 - (s2 - s1)

						--| Close tag processing
					if t.has_closing_item then
						s1 := t.closing_start_index
						s2 := t.closing_end_index
						item_output.replace_substring ("", soffset + s1, soffset + s2)
						soffset := soffset - 1 - (s2 - s1)
					end
				end
				items.forth
			end -- end Loop Iteration
			Result := item_output
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
