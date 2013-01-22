note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	SMARTY_TEST_SET

inherit
	EQA_TEST_SET

	SHARED_TEMPLATE_CONTEXT
		undefine
			default_create
		end

feature -- Test routines

	test_01
			-- New test routine
		local
			template: TEMPLATE_FILE
			data: like new_data
			p: PATH
			s: STRING
		do
			create p.make_current
			p := p.extended ("..").extended ("..").extended ("..").extended ("..").extended ("..").extended ("tpl").canonical_path
			template_context.set_template_folder (p)
--			create template.make_from_file ("index-bug.tpl")
			create template.make_from_file ("index.tpl")
--			create template.make_from_file ("index-id.tpl")

			data := new_data
			create s.make_empty
			append_data_to_string (data, 0, s)

			template.add_value (data, "TheData")

			template_context.enable_verbose
			template.analyze
			template.get_output
			if attached template.output as output then
				print (output)
			end
		end

feature {NONE} -- Implementation

	append_data_to_string (d: ANY; a_offset: INTEGER; a_result: STRING)
		local
			o: STRING
		do
			create o.make_filled (' ', a_offset * 2)
			if attached {Z_TREE} d as z_tree then
				across
					z_tree.nodes as c
				loop
					append_data_to_string (c.item, a_offset + 1, a_result)
				end
			elseif attached {Z_TREE_NODE} d as z_tree_node then
				a_result.append (o)
--				a_result.append (z_tree_node.name + "#" + z_tree_node.id.out + "%N")
				a_result.append ("- " + z_tree_node.name)
				if attached {Z_TREE_ITEM} z_tree_node as z_tree_item then
					a_result.append (" (#" + z_tree_item.nodes.count.out + ")%N")
					across
						z_tree_item.nodes as c
					loop
						append_data_to_string (c.item, a_offset + 1, a_result)
					end
				else
					a_result.append ("%N")
				end
			end
		end

	new_data: Z_TREE
		local
			z_item: Z_TREE_ITEM
			z_tree: Z_TREE
		do
			create z_tree.make ("My test tree")

			create z_item.make ("part A")
			z_tree.add_node (z_item)
			z_item.add_node (create {Z_TREE_ITEM}.make ("item a1"))
			z_item.add_node (create {Z_TREE_ITEM}.make ("item a2"))
			z_item.add_node (create {Z_TREE_ITEM}.make ("item a3"))

			if attached {Z_TREE_ITEM} z_item.nodes.first as l_z_item then
				l_z_item.add_node (create {Z_TREE_ITEM}.make ("a1 - i"))
				l_z_item.add_node (create {Z_TREE_ITEM}.make ("a1 - ii"))
				l_z_item.add_node (create {Z_TREE_ITEM}.make ("a1 - iii"))
			end

			create z_item.make ("part B")
			z_tree.add_node (z_item)
			z_item.add_node (create {Z_TREE_ITEM}.make ("item b1"))
			z_item.add_node (create {Z_TREE_ITEM}.make ("item b2"))
			z_item.add_node (create {Z_TREE_ITEM}.make ("item b3"))

			Result := z_tree
		end

end


