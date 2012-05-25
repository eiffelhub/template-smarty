note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEMPLATE_STRUCTURE_VARIABLE

inherit
	TEMPLATE_STRUCTURE_ITEM
		rename
			forced_output as forced_value,
			set_forced_output as set_forced_value
		redefine
			forced_value, set_forced_value,
			get_output
		end

create
	make

feature {NONE} -- Initialization

feature -- Output

	get_output
		do
			Precursor
			if output = Void then
				if variable_name /= Void then
					if runtime_values.has (variable_name) then
						output := string_value (runtime_values.item (variable_name))
					elseif template_context.runtime_values.has (variable_name) then
						output := string_value (template_context.runtime_values.item (variable_name))
					elseif template_context.values.has (variable_name) then
						output := string_value (template_context.values.item (variable_name))
					else
						output := "{!! Error = No value for " + variable_name + " variable !!}"
					end
				elseif variable_expression /= Void then
					output := string_value (resolved_expression (variable_expression))
				end
			end
		end

feature -- Access

	variable_name: STRING

	variable_expression: STRING

	forced_value: STRING

feature -- Change

	set_variable_name (v: like variable_name)
		do
			variable_name := v
			name := v
		end

	set_variable_expression (v: like variable_expression)
		do
			variable_expression := v
			name := v
		end

	set_forced_value (v: like forced_value)
		do
			forced_value := v
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
