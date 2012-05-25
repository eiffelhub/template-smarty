note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEMPLATE_TEXT

inherit
	TEMPLATE_COMMON

create
	make_from_text

feature {NONE} -- Initialization

	make_from_text (t: STRING)
			-- Initialize `Current'.
		require
			t /= Void
		do
			text := t
			init_values
		end

	init_values
		do
			create values.make (10)
		end

feature -- Reset

	clear_values
		do
			values.wipe_out
		end

	clear
		do
			clear_values
			name := Void
			text := Void
			structure_item := Void
		end

feature -- Values

	values: DS_HASH_TABLE [ANY, STRING]

	set_values (v: like values)
		do
			values := v
		end

	append_values (v: like values)
		do
			from
				v.start
			until
				v.after
			loop
				add_value (v.item_for_iteration, v.key_for_iteration)
				v.forth
			end
		end

	add_value (aval: ANY; aname: STRING)
		do
			values.force (aval, aname)
		end

feature -- Properties

	name: STRING

	text: STRING

feature -- Get	

	has_structure: BOOLEAN
		do
			Result:= structure_item /= Void
		end

	has_text: BOOLEAN
		do
			Result:= text /= Void
		end

	is_ignoring_error: BOOLEAN = True

	last_structure_item: TEMPLATE_STRUCTURE_ACTION

	get_structure
		local
			r, rsc, rsa, rse, rsv : RX_PCRE_REGULAR_EXPRESSION
			str: STRING
			tagname: STRING
			s1, s2: INTEGER
			current_item, struct_item: TEMPLATE_STRUCTURE_ITEM
			act_item: TEMPLATE_STRUCTURE_ACTION
			var_item: TEMPLATE_STRUCTURE_VARIABLE
			error: BOOLEAN
			error_message: STRING
			is_scanning: BOOLEAN
			found_tag_closing_slash: BOOLEAN
			found_tag_open_closed_slash: BOOLEAN
			found_tag_inside_text: STRING
--			i: INTEGER
		do
			create structure_item.make
			current_item := structure_item

			r := Tag_regexp_tag
			rsc := Tag_regexp_sub_closing_tag
			rsv := Tag_regexp_sub_var
			rse := Tag_regexp_sub_expression
			rsa := Tag_regexp_sub_action
			if
				r.is_compiled
				and rsc.is_compiled
				and rsv.is_compiled
				and rse.is_compiled
				and rsa.is_compiled
			then
				from
					is_scanning := True
					r.match (text)
				until
					not r.has_matched or (error and not is_ignoring_error)
				loop
						-- Reset ..
					error := False
					error_message := Void
					struct_item := Void
					tagname := Void

						-- Let's go
					found_tag_closing_slash := r.captured_substring (1).is_equal ("/")
					found_tag_open_closed_slash := r.captured_substring (r.match_count - 1).is_equal ("/")
					if found_tag_closing_slash then
						s1 := r.captured_end_position (1) + 1
					else
						s1 := r.captured_start_position (2)
					end
					if found_tag_open_closed_slash then
						s2 := r.captured_start_position (r.match_count - 1) - 1
					else
						s2 := r.captured_end_position (0) - 1
					end
					found_tag_inside_text := text.substring (s1, s2)

					s1 := r.captured_start_position (0)
					s2 := r.captured_end_position (0)
					debug ("template")
						print (" - " + r.captured_substring (2))
						print (" = [" + s1.out + "-" + s2.out + "]")
						print ("%N")
					end
					if found_tag_closing_slash then
						--| closing tag
						str := found_tag_inside_text
						rsc.match (str)
						if rsc.has_matched then
							tagname := rsc.captured_substring (1)
							if
								current_item.name /= Void
							then
								if current_item.name.is_equal (tagname) then
									current_item.set_is_closed (True)
									current_item.set_closing_indexes (s1, s2)
									current_item := current_item.parent
								else
									error := True;
									error_message := "Closing tag [" + tagname + "] does not match tag [" + current_item.name + "]"
								end
							else
								error := True;
								error_message := "Closing tag [" + tagname + "] without starting tag"
							end
						else
							error := True
							error_message := "Closing tag [" + str + " is not valid"
						end
						if
							not error
							and then tagname /= Void
							and then tagname.is_equal (literal_op_id)
						then
							is_scanning := True
						end
					elseif is_scanning then
						act_item := Void
						check struct_item = Void end
						str := found_tag_inside_text
						debug ("template")
							print (str + "%N")
						end
						if found_tag_open_closed_slash then
							--| open/closed tag
							rsv.match (str)
							if rsv.has_matched then
								--| is a variable tag
								create var_item.make
								tagname := rsv.captured_substring (1)
								var_item.set_variable_name (tagname)
								struct_item := var_item
							else
								rse.match (str)

								if rse.has_matched then
									--| is a variable/expression tag
									create var_item.make
									tagname := str
									var_item.set_variable_expression (tagname)
									struct_item := var_item
								else -- not a variable : action ...
									act_item := action_item_from_string (str)
									if act_item /= Void then
										struct_item := act_item
									else
										error := True
										error_message := "Action tag [" + str + "] is not yet available"
									end
								end
							end
							if struct_item /= Void then
								current_item.put_item_last (struct_item)
							end
						else
							--| opening tag => then action tag !!
							rsa.match (str)
							if rsa.has_matched then
								--| is a action tag
								if
									current_item.name /= Void
									and then current_item.name.is_equal (if_op_id)
									and then str.is_equal ("else")
								then
									current_item.add_indexes (s1, s2)
									struct_item := Void
								else
									act_item := action_item_from_string (str)
									if act_item /= Void then
										struct_item := act_item
									else
										error := True
										error_message := "Action tag [" + str + "] is not yet available"
									end
								end
							else
								-- Not Yet Available
								error := True
								error_message := "Invalid tag: [" + str + "]"
							end
							if struct_item /= Void then
								current_item.put_item_last (struct_item)
								current_item := struct_item
							end
						end
						if act_item /= Void and then act_item.is_literal_action then
								-- Stop scanning for structure until closing tag "{/literal}"
							is_scanning := False
						end
						if struct_item /= Void then
							struct_item.add_indexes (s1, s2)
						end
					end
					if error and then error_message /= Void then
						debug ("template")
							print ("ERROR : " + error_message + "%N")
						end
						create struct_item.make
						struct_item.add_indexes (s1, s2)
						struct_item.set_name ("!error!")
						struct_item.set_error_output ("{!! " + error_message + "!!}")
						current_item.put_item_last (struct_item)
					end
					debug ("template")
						print ("%N")
					end

					r.next_match
				end
			end
		end

	Tpl_action_factory: TEMPLATE_STRUCTURE_ACTION_FACTORY
		once
			create Result
		end

	action_item_from_string (s: STRING): TEMPLATE_STRUCTURE_ACTION
		local
			r: like Tag_regexp_sub_action_op_val
			an: STRING
			txt: STRING
			sval: STRING
			skey: STRING
		do
			r := Tag_regexp_sub_action_name
			r.match (s)
			if r.has_matched then
				an := r.captured_substring (1)
				Result := Tpl_action_factory.new_action (an)
				txt := s.substring (r.captured_end_position (1) + 1, s.count)
				r := Tag_regexp_sub_action_op_val
				from
					r.match (txt)
				until
					not r.has_matched
				loop
					sval := r.captured_substring (2)
					skey := r.captured_substring (1)
					Result.add_parameter (sval, skey)
					r.next_match
				end
			end
		end

	print_structure (s: TEMPLATE_STRUCTURE_ITEM; alevel: INTEGER)
		local
			lst: DS_LIST [TEMPLATE_STRUCTURE_ITEM]
			vn: STRING
			tab: STRING
			i: INTEGER
		do
			from
				i := 0
				tab := ""
			until
				i = alevel
			loop
				tab.append_string (" ")
				i := i + 1
			end
			vn := s.name
			if vn /= Void then
				print (tab + "Name = " + vn + " [" + s.start_index.out + "-" + s.end_index.out + "] %N")
			end
			from
				lst := s.items
				lst.start
			until
				lst.after
			loop
				print_structure (lst.item_for_iteration, alevel + 1)
				lst.forth
			end
		end

feature -- Access

	output: STRING

	get_output
		require
			has_structure: has_structure
		local
		do
			-- FIXME: factorize with TEMPLATE_STRUCTURE_ACTION process_foreach !!
			output := Void
			template_context.clear
			template_context.set_current_template_text (Current)
			process_structure (structure_item)
		end

feature {NONE} -- Impl

	process_structure (struct: TEMPLATE_STRUCTURE_ITEM)
		local
			t: TEMPLATE_STRUCTURE_ITEM
			ta: TEMPLATE_STRUCTURE_ACTION
			lst: DS_LIST [TEMPLATE_STRUCTURE_ITEM]
			val: STRING
			s1, s2: INTEGER
			soffset: INTEGER
		do
			from
				lst := struct.items
				lst.start
				soffset := 0
				output := text.twin
			until
				lst.after
			loop
				t := lst.item_for_iteration
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
					output.replace_substring (val, soffset + s1, soffset + s2)
					soffset := soffset + val.count - 1 - (s2 - s1)
				else
					output.replace_substring (val, soffset + s1, soffset + s2)
					soffset := soffset + val.count - 1 - (s2 - s1)

						--| Process sub items ...
					-- Already done by the .._ACTION item

						--| Close tag processing
					if t.has_closing_item then
						s1 := t.closing_start_index
						s2 := t.closing_end_index
						output.replace_substring ("", soffset + s1, soffset + s2)
						soffset := soffset - 1 - (s2 - s1)
					end
				end
				lst.forth
			end
		end

feature {TEMPLATE_COMMON} -- Implementation

	structure_item: TEMPLATE_STRUCTURE_ITEM
			-- Id, VarName, start_index, end_index

feature {NONE} -- Impl

	compiled_regexp (p: STRING; caseless: BOOLEAN): RX_PCRE_REGULAR_EXPRESSION
		require
			p /= Void
		do
			create Result.make
			Result.set_caseless (caseless)
			Result.compile (p)
		ensure
			Result.is_compiled
		end

	Tag_regexp_tag: RX_PCRE_REGULAR_EXPRESSION
				-- {$varname/}
				-- {action .... /}
				-- {action .... }...{/action}
				--| grp (1) -> is or not a closing tag
				--| grp (2) -> string to process ...
				--| grp (3) -> is or not a open/closed tag
		local
			p: STRING
		once
--			p := "\{(\/)?\s*((%"[^%"]*%"|[^/^}])+)\s*(\/)?\}"
			p := "[\r\n]?\{(\/)?\s*((%"[^%"]*%"|[^/^}])+)\s*(\/)?\}" -- with CR
			Result := compiled_regexp (p, True)
		end

	Tag_regexp_sub_closing_tag: RX_PCRE_REGULAR_EXPRESSION
				-- {$varname/}
				-- {action .... /}
				-- {action .... }...{/action}
				--| grp (1) -> is or not a closing tag
				--| grp (2) -> string to process ...
				--| grp (3) -> is or not a open/closed tag
		once
			Result := compiled_regexp ("\s*([a-zA-Z0-9_]+)\s*", True)
		end

	Tag_regexp_sub_var: RX_PCRE_REGULAR_EXPRESSION
				-- "{ $var_name /}"
		once
			Result := compiled_regexp ("^\s*\$([a-zA-Z0-9_]+)\s*$", True)
		end

	Tag_regexp_sub_expression: RX_PCRE_REGULAR_EXPRESSION
				-- "{ $var_name /}"
		once
			Result := compiled_regexp ("^\s*\$([a-zA-Z0-9_]+)([\.a-zA-Z0-9_]+)\s*$", True)
		end

	Tag_regexp_sub_action: RX_PCRE_REGULAR_EXPRESSION
				-- "{$var_name /}{action_name ...}...{/action_name}
		once
			Result := compiled_regexp ("^\s*([a-zA-Z]+)\s*", True)
		end

	Tag_regexp_sub_action_name: RX_PCRE_REGULAR_EXPRESSION
				-- "action_var_name"
		once
			Result := compiled_regexp ("^\s*([a-z0-9_]+)(\s|$)", True)
		end

	Tag_regexp_sub_action_op_val: RX_PCRE_REGULAR_EXPRESSION
				-- "action_var_name"
		once
--			Result := compiled_regexp ("([a-z0-9_]+)=(%"[^%"]*%"|\$[\s^]+)", True)
			Result := compiled_regexp ("([a-z0-9_]+)=%"([^%"]*)%"", True)
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
