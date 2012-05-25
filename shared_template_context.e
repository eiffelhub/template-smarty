note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_TEMPLATE_CONTEXT

feature {NONE} -- Template context

	template_context: TEMPLATE_CONTEXT
		once
			create Result.make
		end

	template_custom_action_by_id (a_id: STRING): FUNCTION [ANY, TUPLE [STRING, DS_HASH_TABLE [STRING, STRING]], STRING]
		do
			Result := template_context.template_custom_actions.item (a_id)
		end

	is_valid_template_custom_action_id (a_id: STRING): BOOLEAN
		do
			Result := template_context.template_custom_actions.has (a_id)
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end -- class SHARED_TEMPLATE_CONTEXT
