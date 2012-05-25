note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2010-06-11 09:18:42 +0200 (Fri, 11 Jun 2010) $"
	revision    : "$Revision: 401 $"

class
	TEMPLATE_STRUCTURE_ACTION_GENERIC

inherit
	TEMPLATE_STRUCTURE_ACTION
		redefine
			process,
			set_action_name
		end

create {TEMPLATE_STRUCTURE_ACTION_FACTORY}
	make

feature {TEMPLATE_TEXT} -- Type

	is_if_action,
	is_unless_action,
	is_include_action,
	is_invalid_action: BOOLEAN

	reset_type
		do
			is_if_action := False
			is_unless_action := False
			is_include_action := False
			is_invalid_action := False
		end

	update_type
		require
			action_name /= Void
		do
			reset_type
			if action_name.is_equal (if_op_id) then
				is_if_action := True
			elseif action_name.is_equal (if_unless_id) then
				is_unless_action := True
			elseif action_name.is_equal (include_op_id) then
				is_include_action := True
			else
				is_invalid_action := True
			end
		end

feature -- Output

	process
		local
		do
			Precursor
			if is_if_action then
				process_if_unless (True)
			elseif is_unless_action then
				process_if_unless (False)
			elseif is_include_action then
				process_include
			elseif is_invalid_action then
			end
		end

feature -- Change

	set_action_name (v: like action_name)
		do
			Precursor (v)
			update_type
		end

feature {NONE} -- Implementation

	process_include
		require
			is_include_action
		local
			vn: STRING
			f: KL_TEXT_INPUT_FILE
			t: STRING
			fc: INTEGER
			fn: FILE_NAME
			is_literal: BOOLEAN
			templ_text: TEMPLATE_TEXT
		do
			if parameters.has (file_param_id) then
				vn := parameters.item (file_param_id)
			end
			if (create {KL_SHARED_FILE_SYSTEM}).file_system.is_absolute_pathname (vn) then
			else
				create fn.make_from_string (template_context.template_folder)
				fn.set_file_name (vn)
				vn := fn
			end
			if vn /= Void then
				create f.make (vn)
				if f.exists then
					fc := f.count
					if fc > 0 then
						f.open_read
						f.read_string (fc)
						t := f.last_string
						f.close
					end
				else
					set_error_output ("{!! Missing include file " + vn + " !!}")
				end
			else
				set_error_output ("{!! Invalid use of action include !!}")
			end

			if t /= Void then
				if parameters.has (literal_param_id) then
					vn := parameters.item (literal_param_id)
					vn.to_lower
					is_literal := vn.is_equal ("true")
				else
					is_literal := False
				end
				if is_literal then
					set_forced_output (t)
				else
					if not items.is_empty then
						t.prepend_string (inside_text)
					end
					create templ_text.make_from_text (t)
					templ_text.set_values (template_context.values.twin)

					template_context.backup
					template_context.set_current_template_text (templ_text)
					templ_text.get_structure

					templ_text.get_output
					t := templ_text.output
					template_context.restore
					set_forced_output (t)
				end
			end
		end

	process_if_unless (is_if: BOOLEAN)
		require
			is_if_action or is_unless_action
		local
			vn: STRING
			cond_isset: BOOLEAN
			cond_isempty: BOOLEAN
			vv: ANY
			vbool: BOOLEAN_REF
			vstring: STRING
			vcontainer: DS_CONTAINER [ANY]
			vvout: STRING
			cond: BOOLEAN
			item_output: STRING
		do
			if parameters.has (condition_param_id) then
				vn := parameters.item (condition_param_id)
			end
			if parameters.has (isset_param_id) then
				vn := parameters.item (isset_param_id)
				cond_isset := True
			end
			if parameters.has (isempty_param_id) then
				vn := parameters.item (isempty_param_id)
				cond_isempty := True
			end
			if vn /= Void and then not vn.is_empty then
				vv := resolved_expression (vn)

				if vv = Void then
					if cond_isempty then
						cond := True
					else
						cond := False
					end
				else
					if cond_isset then
						cond := True
					else
						if cond_isempty then
							vstring ?= vv
							if vstring /= Void then
								cond := vstring.is_empty
							else
								vcontainer ?= vv
								if vcontainer /= Void then
									cond := vcontainer.is_empty
								else
									cond := False
								end
							end
						else
							vbool ?= vv
							if vbool /= Void then
								cond := vbool.item
							else
								vvout := vv.out
								vvout.to_lower
								if vvout.is_equal ("true") then
									cond := True
								end
							end
						end
					end
				end
			end
			if (is_if and cond) or (not is_if and not cond) then
				item_output := foreach_iteration_string (inside_text, False)
				set_forced_output (item_output)
			else
				set_forced_output ("")
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
