note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEMPLATE_CONTEXT

create
	make

feature

	make
		do
			create runtime_values.make (10)
			create archives.make
			create template_custom_actions.make (3)
			template_custom_actions.compare_objects
		end

	clear_values
		do
			runtime_values.wipe_out
		end

	clear
		do
			current_template_text := Void
		end

	runtime_values: DS_HASH_TABLE [ANY, STRING]

	current_template_text: TEMPLATE_TEXT

	current_template_string: STRING
		do
			Result := current_template_text.text
		end

	values: DS_HASH_TABLE [ANY, STRING]
		require
			current_template_text /= Void
		do
			Result := current_template_text.values
		end

	template_folder: STRING

feature -- Backup

	backup
		do
			archives.put_last ([current_template_text, runtime_values])
			runtime_values := runtime_values.deep_twin
		end

	restore
		require
			has_archive: not archives.is_empty
		local
			b: TUPLE [tpl_text: like current_template_text; rt_values: like runtime_values]
		do
			b := archives.last
			current_template_text := b.tpl_text
			runtime_values := b.rt_values
			archives.remove_last
		end

	archives: DS_LINKED_LIST [ TUPLE [like current_template_text, like runtime_values]]

feature -- Change

	set_template_folder (v: like template_folder)
		do
			template_folder := v
		end

	set_current_template_text (v: like current_template_text)
		do
			current_template_text := v
		end

	add_runtime_value (va: ANY; ks: STRING)
		do
			runtime_values.force (va, ks)
		end

	remove_runtime_value (ks: STRING)
		do
			runtime_values.remove (ks)
		end

	add_value (va: ANY; ks: STRING)
		require
			current_template_text /= Void
		do
			values.force (va, ks)
		end

	remove_value (ks: STRING)
		require
			current_template_text /= Void
		do
			values.remove (ks)
		end

	append_values (v: like values)
		require
			current_template_text /= Void
		local
			c: DS_HASH_TABLE_CURSOR [ANY, STRING]
		do
			from
				c := v.new_cursor
				c.start
			until
				c.after
			loop
				add_value (c.item, c.key)
				c.forth
			end
		end

feature -- Specific custom actions

	template_custom_actions: HASH_TABLE [like template_custom_action_by_id, STRING]

	template_custom_action_by_id (a_id: STRING): FUNCTION [ANY, TUPLE [STRING, DS_HASH_TABLE [STRING, STRING]], STRING]
		do
			Result := template_custom_actions.item (a_id)
		end

	is_valid_template_custom_action_id (a_id: STRING): BOOLEAN
		do
			Result := template_custom_actions.has (a_id)
		end

feature -- Option

	enable_verbose
		do
			verbose := True
		end

	verbose: BOOLEAN

feature -- Caching

	Files: DS_HASH_TABLE [TEMPLATE_FILE , STRING]
		once
			create Result.make (10)
		end


note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end -- class TEMPLATE_CONTEXT