note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TEMPLATE_FILE

inherit
	TEMPLATE_COMMON

create
	make_from_file

feature {NONE} -- Initialization

	make_from_file (fn: STRING)
			-- Initialize `Current'.
		require
			fn /= Void
		local
			l_fn: FILE_NAME
		do
			if (create {KL_SHARED_FILE_SYSTEM}).File_system.is_absolute_pathname (fn) then
				file_name := fn
			else
				if template_context.template_folder /= Void then
					create l_fn.make_from_string (template_context.template_folder)
					l_fn.set_file_name (fn)
					file_name := l_fn
				else
					file_name := fn
				end
			end
			create values.make (10)
		end

feature -- Reset

	clear_values
		do
			values.wipe_out
			if template_text /= Void then
				template_text.clear_values
			end
		end

	clear
		do
			clear_values
			text := Void
			template_text := Void
		end

feature -- Values

	values: DS_HASH_TABLE [ANY, STRING]

	add_value (aval: ANY; aname: STRING)
		do
			values.force (aval, aname)
		end

feature -- Properties

	file_name: STRING

	text: STRING

	template_text: TEMPLATE_TEXT

feature -- Get	

	analyze
		do
			get_structure
		end

	has_template_text: BOOLEAN
		do
			Result:= template_text /= Void
		end

	has_structure: BOOLEAN
		do
			Result:= has_template_text and then template_text.structure_item /= Void
		end

	has_text: BOOLEAN
		do
			Result:= text /= Void
		end

	get_text
		local
			l_file: KL_TEXT_INPUT_FILE
			c: INTEGER
		do
			create l_file.make (file_name)
			c := l_file.count
			l_file.open_read
			l_file.read_string (c)
			text := l_file.last_string.twin
			l_file.close
			l_file := Void
		end

	get_structure
		local
			tf: TEMPLATE_FILE
		do
			if Template_context.Files.has (file_name) then
				tf := Template_context.Files.item (file_name)
				template_text := tf.template_text.twin
				template_text.clear_values
			else
				if not has_text then
					get_text
				end
				create template_text.make_from_text (text)
				template_text.get_structure
				debug ("template")
					print_structure (template_text.structure_item, 0)
				end
			end
		end

	print_structure (s: TEMPLATE_STRUCTURE_ITEM; alevel: INTEGER)
		do
			template_text.print_structure (template_text.structure_item, 0)
		end

feature -- Access

	output: STRING

	get_output
		require
			has_template_text: has_template_text
			has_structure: has_structure
		do
			template_text.set_values (values)
			template_text.get_output
			output := template_text.output
		end

note
	copyright: "2011-2012, Jocelyn Fiat"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Jocelyn Fiat
			Contact: http://about.jocelynfiat.net/
		]"
end
