note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2010-06-11 09:18:42 +0200 (Fri, 11 Jun 2010) $"
	revision    : "$Revision: 401 $"

class
	TEMPLATE_STRUCTURE_ACTION_FOREACH

inherit
	TEMPLATE_STRUCTURE_ACTION
		redefine
			process, get_output
		end

create {TEMPLATE_STRUCTURE_ACTION_FACTORY}
	make

feature -- Output

	process
		do
			Precursor
			process_foreach
		end

	get_output
		do
			Precursor
--			if output = Void then
--				if is_foreach_action then
--					output := "{!! Action[" + action_name + "] !!}"
--				end
--			end
		end

feature {NONE} -- Implementation

	Reflexion: INTERNAL
		once
			create Result
		end

	Integer_dynamic_type: INTEGER
		once
			Result := reflexion.dynamic_type (0)
		end

	process_foreach
		local
			sfrom, sitem, skey: STRING
			vfrom: ANY
			lst_any: DS_LIST [ANY]
			lst_integer: DS_LIST [INTEGER]
			hsh_any_hashable: DS_HASH_TABLE [ANY, HASHABLE]
			hsh_any_integer: DS_HASH_TABLE [ANY, INTEGER]
			tmp_output: STRING
			gen_count: INTEGER
		do
--			template_context.backup
			if parameters.has (key_param_id) then
				skey := parameters.item (key_param_id)
			end
			if parameters.has (item_param_id) then
				sitem := parameters.item (item_param_id)
			end
			if parameters.has (from_param_id) then
				sfrom := parameters.item (from_param_id)
				vfrom := resolved_expression (sfrom)

				gen_count := Reflexion.generic_count (vfrom)
				if gen_count = 2 then
					if reflexion.generic_dynamic_type (vfrom, 2) = Integer_dynamic_type then
						hsh_any_integer ?= vfrom
					else
						hsh_any_hashable ?= vfrom
					end
				elseif gen_count = 1 then
					if reflexion.generic_dynamic_type (vfrom, 1) = Integer_dynamic_type then
						lst_integer ?= vfrom
					else
						lst_any ?= vfrom
					end
				end
			end
			if hsh_any_hashable /= Void and (skey /= Void or sitem /= Void)	then
				tmp_output := foreach_hash_any_hashable_output (hsh_any_hashable, skey, sitem)
			elseif hsh_any_integer /= Void and (skey /= Void or sitem /= Void)	then
				tmp_output := foreach_hash_any_integer_output (hsh_any_integer, skey, sitem)
			elseif lst_any /= Void and sitem /= Void then
				tmp_output := foreach_list_any_output (lst_any, skey, sitem)
			elseif lst_integer /= Void and sitem /= Void then
				tmp_output := foreach_list_integer_output (lst_integer, skey, sitem)
			end
--			template_context.restore
			if tmp_output /= Void then
				set_forced_output (tmp_output)
			end
		end

	foreach_hash_any_hashable_output (obj: DS_HASH_TABLE [ANY, HASHABLE]; skey, sitem: STRING): STRING
		require
			valid_data: obj /= Void and (skey /= Void or sitem /= Void)
		local
			cursor: DS_HASH_TABLE_CURSOR [ANY, HASHABLE]
			item_output: STRING
			vobj_item: ANY
			vobj_key: HASHABLE
		do
			from
				cursor := obj.new_cursor
				cursor.start
				Result := ""
			until
				cursor.after
			loop
				if sitem /= Void then
					vobj_item := cursor.item
					template_context.add_runtime_value (vobj_item, sitem)
				end

				if skey /= Void then
					vobj_key := cursor.key
					template_context.add_runtime_value (vobj_key, skey)
				end

				item_output := foreach_iteration_string (inside_text, False)
				Result.append_string (item_output)
				cursor.forth
			end
			if sitem /= Void then
				template_context.remove_runtime_value (sitem)
			end
			if skey /= Void then
				template_context.remove_runtime_value (skey)
			end
		end

	foreach_hash_any_integer_output (obj: DS_HASH_TABLE [ANY, INTEGER]; skey, sitem: STRING): STRING
		require
			valid_data: obj /= Void and (skey /= Void or sitem /= Void)
		local
			cursor: DS_HASH_TABLE_CURSOR [ANY, INTEGER]
			item_output: STRING
			vobj_item: ANY
			vobj_key: INTEGER
		do
			from
				cursor := obj.new_cursor
				cursor.start
				Result := ""
			until
				cursor.after
			loop
				if sitem /= Void then
					vobj_item := cursor.item
					template_context.add_runtime_value (vobj_item, sitem)
				end

				if skey /= Void then
					vobj_key := cursor.key
					template_context.add_runtime_value (vobj_key, skey)
				end

				item_output := foreach_iteration_string (inside_text, False)
				Result.append_string (item_output)
				cursor.forth
			end
			if sitem /= Void then
				template_context.remove_runtime_value (sitem)
			end
			if skey /= Void then
				template_context.remove_runtime_value (skey)
			end
		end


	foreach_list_any_output (obj: DS_LIST [ANY]; skey, sitem: STRING): STRING
		require
			data_valid: obj /= Void and sitem /= Void
		local
			cursor: DS_LINEAR_CURSOR [ANY]
			item_output: STRING
			vobj_item: ANY
			i: INTEGER
		do
			from
				i := 0
				cursor := obj.new_cursor
				cursor.start
				Result := ""
			until
				cursor.after
			loop
				i := i + 1
				if sitem /= Void then
					vobj_item := cursor.item
					template_context.add_runtime_value (vobj_item, sitem)
				end
				if skey /= Void then
					template_context.add_runtime_value (i, skey)
				end

				item_output := foreach_iteration_string (inside_text, False)
				Result.append_string (item_output)
				cursor.forth
			end
			if sitem /= Void then
				template_context.remove_runtime_value (sitem)
			end
			if skey /= Void then
				template_context.remove_runtime_value (skey)
			end
		end

	foreach_list_integer_output (obj: DS_LIST [INTEGER]; skey, sitem: STRING): STRING
		require
			data_valid: obj /= Void and sitem /= Void
		local
			cursor: DS_LINEAR_CURSOR [INTEGER]
			item_output: STRING
			vobj_item: INTEGER
			i: INTEGER
		do
			from
				i := 0
				cursor := obj.new_cursor
				cursor.start
				Result := ""
			until
				cursor.after
			loop
				i := i + 1
				if sitem /= Void then
					vobj_item := cursor.item
					template_context.add_runtime_value (vobj_item, sitem)
				end
				if skey /= Void then
					template_context.add_runtime_value (i, skey)
				end

				item_output := foreach_iteration_string (inside_text, False)
				Result.append_string (item_output)
				cursor.forth
			end
			if sitem /= Void then
				template_context.remove_runtime_value (sitem)
			end
			if skey /= Void then
				template_context.remove_runtime_value (skey)
			end
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
