note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEMPLATE_STRUCTURE_ITEM

inherit
	TEMPLATE_COMMON
		redefine
			resolved_formatted_variable
		end

	DEBUG_OUTPUT
		rename
			debug_output as name
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			create items.make
			create runtime_values.make (3)
			create indexes.make
		end

feature -- Access

	name: STRING

	is_closed: BOOLEAN

	has_closing_item: BOOLEAN

	parent: TEMPLATE_STRUCTURE_ITEM

	indexes: DS_LINKED_LIST [INTEGER_INTERVAL]

	start_index: INTEGER
		do
			Result := indexes.first.lower
		end

	end_index: INTEGER
		do
			Result := indexes.first.upper
		end

	closing_start_index: INTEGER
		require
			has_closing_item
		do
			Result := indexes.last.lower
		end

	closing_end_index: INTEGER
		require
			has_closing_item
		do
			Result := indexes.last.upper
		end

	items: DS_LINKED_LIST [TEMPLATE_STRUCTURE_ITEM]

	forced_output: STRING

	error_output: STRING

feature -- Runtime values

	runtime_values: DS_HASH_TABLE [ANY, STRING]

	add_runtime_value (va: ANY; ks: STRING)
		do
			runtime_values.force (va, ks)
		end

feature -- Expression

	resolved_expression (e: STRING): ANY
			-- `e' should be "$var_name.x.y.z"
			-- to improve .. later
		local
			l_exp: STRING
			l_sp_exp: LIST [STRING]
			tmp: ANY
		do
			l_exp := e.twin
			l_exp.left_adjust
			l_exp.right_adjust

			if l_exp.has ('.') then
				from
					l_sp_exp := l_exp.split ('.')
					l_sp_exp.start
					tmp := resolved_variable (l_sp_exp.item)
					l_sp_exp.forth
				until
					l_sp_exp.after or (tmp = Void)
				loop
					tmp := resolved_nested_message (tmp, l_sp_exp.item)
					l_sp_exp.forth
				end
			else
				tmp := resolved_variable (l_exp)
			end
			Result := tmp
		end

	resolved_composed_expression (e: STRING): ANY
		local
			l_exp: STRING
			l_sp_exp: LIST [STRING]
			l_args: LIST [ANY]
			tmp: ANY
			str1, str2: STRING
		do
			l_exp := e.twin
			l_exp.left_adjust
			l_exp.right_adjust
			if l_exp.has (':') then
				from
					l_sp_exp := l_exp.split (':')
					l_sp_exp.start
					create {LINKED_LIST [ANY]} l_args.make
				until
					l_sp_exp.after
				loop
					tmp := resolved_expression (l_sp_exp.item)
					if tmp = Void then
						tmp := l_sp_exp.item
					end
					l_args.extend (tmp)
					l_sp_exp.forth
				end
				from
					l_args.start
					Result := l_args.first
					str1 ?= Result
					if str1 /= Void then
						str1 := str1.twin
					end
					Result := str1
					l_args.forth
				until
					l_args.after or (Result = Void)
				loop
					tmp := l_args.item
					str1 ?= Result
					if Result /= Void and then str1 = Void then
						str1 := Result.out
					end
					str2 ?= tmp
					if tmp /= Void and then str2 = Void then
						str2 := str2.out
					end
					if str1 /= Void and then str2 /= Void then
						str1.append_string (str2)
						Result := str1
					else
						Result := Void
					end
					l_args.forth
				end
			else
				Result := resolved_expression (e)
			end
		end

	resolved_variable (e: STRING): ANY
			-- `e' should be "$var_name"
			-- to improve .. later
		local
			l_exp: STRING
		do
			l_exp := e.twin
			l_exp.left_adjust
			l_exp.right_adjust
			Result := resolved_formatted_variable (l_exp)
		end

	resolved_formatted_variable (exp: STRING): ANY
			-- `exp' should be "$var_name"
			-- to improve .. later
		local
			l_var: STRING
		do
			Result := Precursor (exp)
			if Result = Void then
				l_var := resolved_variable_name (exp)
				if runtime_values.has (l_var) then
					Result := runtime_values.item (l_var)
				end
			end
		end

feature -- Output

	process
		do
		end

	output: STRING

	get_output
		do
			output := Void
			if forced_output /= Void then
				output := forced_output
			elseif error_output /= Void then
				output := error_output
			end
			forced_output := Void
		end

feature -- Change

	set_name (v: like name)
		do
			name := v
		end

	set_parent (v: like parent)
		do
			parent := v
		end

	add_indexes (s1, s2: INTEGER)
		do
			indexes.put_last (s1 |..| s2)
		end

	set_indexes (s1, s2: INTEGER)
		do
			add_indexes (s1, s2)
		end

	set_is_closed (v: BOOLEAN)
		do
			is_closed := v
		end

	set_closing_indexes (s1, s2: INTEGER)
		require
			is_closed
		do
			add_indexes (s1, s2)
			has_closing_item := True
		ensure
			has_closing_item
		end

	prepend (iis: like items)
		do
			items.append_first (iis)
		end

	put_item_front (i: TEMPLATE_STRUCTURE_ITEM)
		do
			items.put_first (i)
			i.set_parent (Current)
		end

	put_item_last (i: TEMPLATE_STRUCTURE_ITEM)
		do
			items.put_last (i)
			i.set_parent (Current)
		end

	set_forced_output (v: like forced_output)
		do
			forced_output := v.twin
		end

	set_error_output (v: like error_output)
		do
			error_output := v.twin
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end -- class TEMPLATE_STRUCTURE_ITEM
