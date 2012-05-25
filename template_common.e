note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

deferred
class
	TEMPLATE_COMMON

inherit
	SHARED_TEMPLATE_CONTEXT

	TEMPLATE_CONSTANTS

feature {NONE} -- Helpers

	string_value (a: ANY): STRING
		do
			if a /= Void then
				Result := a.out
			end
		end

	resolved_variable_name (exp: STRING): STRING
		do
			if exp.item (1).is_equal ('$') then
				Result := exp.substring (2, exp.count)
			else
				Result := exp.twin
			end
		end

	resolved_formatted_variable (exp: STRING): ANY
			-- `e' should be "$var_name"
			-- to improve .. later
		local
			l_var: STRING
		do
			l_var := resolved_variable_name (exp)
			if template_context.runtime_values.has (l_var) then
				Result := template_context.runtime_values.item (l_var)
			elseif template_context.values.has (l_var) then
				Result := template_context.values.item (l_var)
			end
		end

feature {NONE} -- Nested and Internal

	resolved_nested_message (obj: ANY; mesg: STRING): ANY
			-- `e' should be "$var_name"
			-- to improve .. later
		do
			if obj = Void then
				Result := "Call on Void"
			else
				Result := Template_routines.internal_field_value (obj, mesg)
			end
--			if Result = Void then
--				Result := "R[" + mesg + "]"
--			end
		end

	Template_routines: TEMPLATE_ROUTINES
		once
			create Result
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
