note
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEMPLATE_ROUTINES

inherit
	INTERNAL

feature

	internal_field_value (obj: ANY; fdn: STRING): ANY
		require
			obj_not_void: obj /= Void
			field_name_not_void: fdn /= Void
		local
			otn: STRING
			obj_fields: DS_HASH_TABLE [INTEGER, STRING]
			fdn_index: INTEGER
			tpl_inspector: TEMPLATE_INSPECTOR
		do
			otn := type_name (obj)
			if template_inspectors.has (otn) then
				tpl_inspector := Template_inspectors.item (otn)
				tpl_inspector.set_object (obj)
				Result := tpl_inspector.internal_data (fdn)
			else
				if internal_info.has (otn) then
					obj_fields := internal_info.item (otn)
				else
					obj_fields := internal_info_build (obj)
				end
				if obj_fields.has (fdn) then
					fdn_index := obj_fields.item (fdn)
					Result := field (fdn_index, obj)
				end
			end
		end

	internal_info_build (obj: ANY): DS_HASH_TABLE [INTEGER, STRING]
		require
			obj /= Void
		local
			fi, fc: INTEGER
			fn: STRING
			otn: STRING
		do
			otn := type_name (obj)
			from
				fi := 1
				fc := field_count (obj)
				create Result.make (fc)
			until
				fi > fc
			loop
				fn := field_name (fi, obj)
				Result.force (fi, fn)
				fi := fi + 1
			end
			internal_info.force (Result, otn)
		end

	internal_info: DS_HASH_TABLE [DS_HASH_TABLE [INTEGER, STRING], STRING]
		once
			create Result.make (10)
		end

feature -- Inspectors

	register_template_inspector (ti: TEMPLATE_INSPECTOR; ti_name: STRING)
		require
			ti_name /= Void
		do
			template_inspectors.force (ti, ti_name)
		end

	template_inspectors: DS_HASH_TABLE [TEMPLATE_INSPECTOR, STRING]
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
end -- class TEMPLATE_ROUTINES
