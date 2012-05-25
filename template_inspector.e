note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEMPLATE_INSPECTOR

--create
--	default_create,
--	register

feature

	register (a_inspector_name: STRING)
		do
			Template_routines.register_template_inspector (Current, a_inspector_name)
		end

	set_object (obj: like object)
		do
			object := obj
		end

	object: ANY

feature {TEMPLATE_ROUTINES}

	internal_data (field_name: STRING): ANY
		deferred
		end

feature -- Routine

	template_routines: TEMPLATE_ROUTINES
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
end -- class TEMPLATE_INSPECTOR
