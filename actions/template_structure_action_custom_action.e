note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2010-06-11 09:18:42 +0200 (Fri, 11 Jun 2010) $"
	revision    : "$Revision: 401 $"

class
	TEMPLATE_STRUCTURE_ACTION_CUSTOM_ACTION

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
			if is_valid_template_custom_action_id (action_name) then
				process_custom_action
			end
		end

feature {NONE} -- Implementation

	process_custom_action
		local
			item_output: STRING
			fct: like template_custom_action_by_id
		do
--			template_custom_actions			
			fct := template_custom_action_by_id (action_name)
			if fct /= Void then
				item_output := foreach_iteration_string (inside_text, False)
				item_output := fct.item ([item_output, parameters])
			else
				item_output := foreach_iteration_string (inside_text, False)
			end
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
