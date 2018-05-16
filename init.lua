
wesh = {
	name = "wesh",
	modpath = minetest.get_modpath(minetest.get_current_modname()),
	vt_size = 72,
	player_canvas = {}
}

-- ========================================================================
-- initialization functions
-- ========================================================================

function wesh._init()
	wesh.temp_path = minetest.get_worldpath() .. "/mod_storage/" .. wesh.name
	wesh.gen_prefix = "mesh_"

	if not minetest.mkdir(wesh.temp_path) then
		error("[" .. wesh.name .. "] Unable to create folder " .. wesh.temp_path)
	end
	wesh._init_vertex_textures()
	wesh._init_colors()
	wesh._init_geometry()
	wesh._move_temp_files()
	wesh._load_mod_meshes()
	wesh._main_bindings()
end

function wesh._main_bindings()
	minetest.register_on_player_receive_fields(wesh.on_receive_fields)

	minetest.register_craft({
		output = "wesh:canvas",
		recipe = {
			{'group:wool', 'group:wool', 'group:wool'},
			{'group:wool', 'default:bronze_ingot', 'group:wool'},
			{'group:wool', 'group:wool', 'group:wool'},
		}
	})

	minetest.register_node("wesh:canvas", {
		drawtype = "mesh",
		mesh = "zzz_wesh_canvas.obj",
		tiles = { "wool-72.png" },
		paramtype2 = "facedir",
		on_rightclick = wesh.canvas_interaction,
		description = "Woolen Mesh Canvas",
		walkable = true,
		groups = { dig_immediate = 3},
	})
end

-- creates a 4x4 grid of UV mappings, each with a margin of one pixel
function wesh._init_vertex_textures()
	local vt = ""
	local space = wesh.vt_size / 4
	local tile = space - 2
	local offset = tile / 2
	local start = offset + 1
	local stop = start + 3 * space
	local mult = 1 / wesh.vt_size
	for y = start, stop, space do
		for x = start, stop, space do
			vt = vt .. "vt " .. ((x + offset) * mult) .. " " .. ((y + offset) * mult) .. "\n" -- top right
			vt = vt .. "vt " .. ((x + offset) * mult) .. " " .. ((y - offset) * mult) .. "\n" -- bottom right
			vt = vt .. "vt " .. ((x - offset) * mult) .. " " .. ((y - offset) * mult) .. "\n" -- bottom left
			vt = vt .. "vt " .. ((x - offset) * mult) .. " " .. ((y + offset) * mult) .. "\n" -- top left
		end
	end
	wesh.vertex_textures = vt
end

function wesh._init_colors()
	wesh.colors = {
		"violet", 
		"white", 
		"yellow", 
		"air", 
		"magenta", 
		"orange", 
		"pink", 
		"red", 
		"dark_green", 
		"dark_grey", 
		"green", 
		"grey", 
		"black",      
		"blue",      
		"brown", 
		"cyan", 
	}
	
--	The following loop populates the color_vertices table with data like this...
--	
--	wesh.color_vertices = {
--		violet 		= { 1, 2, 3, 4 },
--		white       = { 5, 6, 7, 8 },
--	
--	...and so forth, in a boring sequence.
--	
--	Such indices will refer to the vt sequence generated by _init_vertex_textures()

	wesh.color_vertices = {}
	for i, color in ipairs(wesh.colors) do
		local t = {}
		local j = (i - 1) * 4 + 1
		for k = j, j + 3 do
			table.insert(t, k)
		end
		wesh.color_vertices[color] = t
	end
end

function wesh._init_geometry()

	-- helper table to build the six faces
	wesh.cube_vertices = {
		{ x =  1, y = -1, z = -1 }, -- 1
		{ x = -1, y = -1, z = -1 }, -- 2
		{ x = -1, y = -1, z =  1 }, -- 3
		{ x =  1, y = -1, z =  1 }, -- 4
		{ x =  1, y =  1, z = -1 }, -- 5
		{ x =  1, y =  1, z =  1 }, -- 6
		{ x = -1, y =  1, z =  1 }, -- 7
		{ x = -1, y =  1, z = -1 }, -- 8
	}

	-- vertices refer to the above cube_vertices table
	wesh.face_construction = {
		bottom = { vertices = { 1, 2, 3, 4}, normal = 1 },
		top    = { vertices = { 5, 6, 7, 8}, normal = 2 },
		back   = { vertices = { 1, 5, 8, 2}, normal = 3 },
		front  = { vertices = { 3, 7, 6, 4}, normal = 4 },
		left   = { vertices = { 5, 1, 4, 6}, normal = 5 },
		right  = { vertices = { 2, 8, 7, 3}, normal = 6 },
	}
	
	wesh.face_normals = {
		{x =  0, y = -1, z =  0 },
		{x =  0, y =  1, z =  0 },
		{x =  0, y =  0, z = -1 },
		{x =  0, y =  0, z =  1 },
		{x = -1, y =  0, z =  0 },
		{x =  1, y =  0, z =  0 },
	}
	
	-- helper mapper for transformation functions
	-- only upright canvases supported
	wesh._transfunc = {
		-- facedir 0, +Y, no rotation
		function(p) return p end,
		-- facedir 1, +Y, 90 deg
		function(p) p.x, p.z = p.z, -p.x return p end,
		-- facedir 2, +Y, 180 deg
		function(p) p.x, p.z = -p.x, -p.z return p end,
		-- facedir 3, +Y, 270 deg
		function(p) p.x, p.z = -p.z, p.x return p end,
	}
end

function wesh._reset_geometry()
	wesh.matrix = {}
	wesh.vertices = {}
	wesh.vertices_indices = {}
	wesh.faces = {}
	wesh.traverse_matrix(function(p)
		if not wesh.matrix[p.x] then wesh.matrix[p.x] = {} end
		if not wesh.matrix[p.x][p.y] then wesh.matrix[p.x][p.y] = {} end
		wesh.matrix[p.x][p.y][p.z] = "air"	
	end)
end

-- ========================================================================
-- core functions
-- ========================================================================

-- called when the player right-clicks on a canvas block
function wesh.canvas_interaction(clicked_pos, node, clicker)
	wesh.player_canvas[clicker:get_player_name()] = { pos = clicked_pos, facedir = node.param2 };
	local formspec = "field[meshname;Enter the name for your mesh;]field_close_on_enter[meshname;false]"
	minetest.show_formspec(clicker:get_player_name(), "save_mesh", formspec)
end

function wesh.on_receive_fields(player, formname, fields)
	if formname == "save_mesh" then
		local canvas = wesh.player_canvas[player:get_player_name()]
		wesh.save_new_mesh(canvas.pos, canvas.facedir, player, fields.meshname)
	end
end

function wesh.save_new_mesh(canvas_pos, facedir, player, description)
	-- empty all helper variables
	wesh._reset_geometry()
	
	-- read all nodes from the canvas space in the world
	-- extract the colors and put them into a helper matrix of color voxels
	wesh.traverse_matrix(wesh.node_to_voxel, canvas_pos, facedir)
	
	-- generate faces according to voxels
	wesh.traverse_matrix(wesh.voxel_to_faces)
	
	-- this will be the actual content of the .obj file
	local vt_section = wesh.vertex_textures
	local v_section = wesh.vertices_to_string()
	local vn_section = wesh.normals_to_string()
	local f_section = table.concat(wesh.faces, "\n")
	local meshdata = vt_section .. v_section .. vn_section .. f_section
	
	wesh.save_mesh_to_file(meshdata, description, player)
end

-- ========================================================================
-- mesh management helpers
-- ========================================================================

function wesh.save_mesh_to_file(meshdata, description, player)
	local sanitized_meshname = wesh.check_plain(description)
	if sanitized_meshname:len() < 3 then
		wesh.notify(player, "Mesh name too short, try again (min. 3 chars)")
		return
	end
	
	local obj_filename = wesh.gen_prefix .. sanitized_meshname .. ".obj"
	for _, entry in ipairs(wesh.get_all_files()) do
		if entry == obj_filename then		
			wesh.notify(player, "Mesh name '" .. description .. "' already taken, pick a new one")
			return
		end
	end
	
	-- save .obj file
	local full_filename = wesh.temp_path .. "/" .. obj_filename
	local file, errmsg = io.open(full_filename, "wb")
	if not file then
		wesh.notify(player, "Unable to write to file '" .. obj_filename .. "' from '" .. wesh.temp_path .. "' - error: " .. errmsg)
		return
	end
	file:write(meshdata)
	file:close()
	
	-- save .dat file
	local data_filename = obj_filename .. ".dat"
	local full_data_filename = wesh.temp_path .. "/" .. data_filename
	local file, errmsg = io.open(full_data_filename, "wb")
	if not file then
		wesh.notify(player, "Unable to write to file '" .. data_filename .. "' from '" .. wesh.temp_path .. "' - error: " .. errmsg)
		return
	end
	file:write(wesh.prepare_data_file(description))
	file:close()
	
	-- save .matrix.dat file
	local matrix_data_filename = obj_filename .. ".matrix.dat"
	local full_matrix_data_filename = wesh.temp_path .. "/" .. matrix_data_filename
	local file, errmsg = io.open(full_matrix_data_filename, "wb")
	if not file then
		wesh.notify(player, "Unable to write to file '" .. matrix_data_filename .. "' from '" .. wesh.temp_path .. "' - error: " .. errmsg)
		return
	end
	file:write(minetest.serialize(wesh.matrix))
	file:close()
	
	
	wesh.notify(player, "Mesh saved to '" .. obj_filename .. "' in '" .. wesh.temp_path .. "', reload the world to move them to the mod folder and enable them")
end

function wesh.get_temp_files()
	return minetest.get_dir_list(wesh.temp_path, false)
end

function wesh.get_stored_files()
	return minetest.get_dir_list(wesh.modpath .. "/models", false)
end

function wesh.get_all_files()
	local all = wesh.get_temp_files()
	for _, entry in pairs(wesh.get_stored_files()) do
		table.insert(all, entry)
	end
	return all
end

function wesh.prepare_data_file(description)
	local output = [[
return {
	description = ]] .. ("%q"):format(description) .. [[,
	variants = {
		wool = "wool-72.png",
		plain = "wool-16.png",
	},
}
]]
	return output
end

function wesh._move_temp_files()
	local meshes = wesh.get_temp_files()
	for _, filename in ipairs(meshes) do
		os.rename(wesh.temp_path .. "/" .. filename, wesh.modpath .. "/models/" .. filename)
	end
end

function wesh._load_mod_meshes()
	local meshes = wesh.get_stored_files()
	for _, filename in ipairs(meshes) do
		if filename:match("^" .. wesh.gen_prefix .. ".-%.obj$") then
			wesh._load_mesh(filename)
		end
	end
end

function wesh._load_mesh(obj_filename)
	local full_data_filename = wesh.modpath .. "/models/" .. obj_filename .. ".dat"
	
	local file = io.open(full_data_filename, "rb")
	
	local data = {}
	if file then
		data = minetest.deserialize(file:read("*all")) or {}
		file:close()
	end
	
	local description = data.description or "Custom Woolen Mesh"
	local variants = data.variants or { plain = "wool-16.png" }
	
	local nodename = obj_filename:gsub("[^%w]+", "_"):gsub("_obj", "")
	
	for variant, tile in pairs(variants) do
		minetest.register_node("wesh:" .. nodename .. "_" .. variant, {
			drawtype = "mesh",
			mesh = obj_filename,
			paramtype2 = "facedir",
			description = description .. " (" .. variant .. ")",
			tiles = { tile },
			walkable = true,
			groups = { dig_immediate = 3 },
		})
	end
end

-- ========================================================================
-- mesh generation helpers
-- ========================================================================

function wesh.construct_face(rel_pos, texture_vertices, facename, vertices, normal_index)
	local normal = wesh.face_normals[normal_index]
	local hider_pos = vector.add(rel_pos, normal)
	if not wesh.out_of_bounds(hider_pos) and wesh.get_voxel_color(hider_pos) ~= "air" then return end
	local face_line = "f "
	for i, vertex in ipairs(vertices) do
		local index = wesh.get_vertex_index(rel_pos, vertex)
		face_line = face_line .. index .. "/" .. texture_vertices[i] .. "/" .. normal_index .. " "
	end
	table.insert(wesh.faces, face_line)
end

function wesh.get_texture_vertices(color)
	if not wesh.color_vertices[color] then
		return wesh.color_vertices.air
	end
	return wesh.color_vertices[color]
end

function wesh.set_voxel_color(pos, color)
	if not wesh.color_vertices[color] then color = "air" end
	wesh.matrix[pos.x][pos.y][pos.z] = color
end

function wesh.get_voxel_color(pos)
	return wesh.matrix[pos.x][pos.y][pos.z]
end

function wesh.get_node_color(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return "trasparent" end
	local parts = string.split(node.name, ":")
	return parts[#parts]
end

function wesh.make_absolute(canvas_pos, facedir, relative_pos)
	-- relative positions range from (1, 1, 1) to (16, 16, 16)

	-- shift relative to canvas node within canvas space
	local shifted_pos = {}
	shifted_pos.y = relative_pos.y - 1
	shifted_pos.x = relative_pos.x - 8
	shifted_pos.z = relative_pos.z
	
	-- transform according to canvas facedir
	local transformed_pos = wesh.transform(facedir, shifted_pos)
		
	-- translate to absolute according to canvas position
	local absolute_pos = vector.add(canvas_pos, transformed_pos)
		
	return absolute_pos
end

function wesh.transform(facedir, pos)
	return (wesh._transfunc[facedir + 1] or wesh._transfunc[1])(pos)
end

function wesh.node_to_voxel(rel_pos, canvas_pos, facedir)
	local abs_pos = wesh.make_absolute(canvas_pos, facedir, rel_pos)
	local color = wesh.get_node_color(abs_pos)
	wesh.set_voxel_color(rel_pos, color)
end

function wesh.voxel_to_faces(rel_pos)
	local color = wesh.get_voxel_color(rel_pos)
	if color == "air" then return end
	for facename, facedata in pairs(wesh.face_construction) do
		local texture_vertices = wesh.get_texture_vertices(color)
		wesh.construct_face(rel_pos, texture_vertices, facename, facedata.vertices, facedata.normal)		
	end
end

function wesh.get_vertex_index(pos, vertex_number)
	-- get integral offset of vertices related to voxel center
	local offset = wesh.cube_vertices[vertex_number]
	
	-- convert integral offset to real offset
	offset = vector.multiply(offset, 1/32)
	
	-- scale voxel center from range 1~16 to range 1/16 ~ 1
	pos = vector.divide(pos, 16)
		
	-- center whole mesh around zero and shift it to make room for offsets
	pos = vector.subtract(pos, 1/2 + 1/32)
	
	-- not really sure whether this should be done here,
	-- but if I don't do this the resulting mesh will be wrongly mirrored
	pos.x = -pos.x
	
	-- combine voxel center and offset to get final real vertex coordinate
	pos = vector.add(pos, offset)
	
	-- bail out if this vertex already exists
	local lookup = pos.x .. "," .. pos.y .. "," .. pos.z
	if wesh.vertices_indices[lookup] then return wesh.vertices_indices[lookup] end
	
	-- add the vertex to the list of needed ones
	table.insert(wesh.vertices, pos)
	wesh.vertices_indices[lookup] = #wesh.vertices
	
	return #wesh.vertices
end

function wesh.vertices_to_string()
	local output = ""
	for i, vertex in ipairs(wesh.vertices) do
		output = output .. "v " .. vertex.x .. " " .. vertex.y .. " " .. vertex.z .. "\n"
	end
	return output
end

function wesh.normals_to_string()
	local output = ""
	for i, normal in ipairs(wesh.face_normals) do
		output = output .. "vn " .. normal.x .. " " .. normal.y .. " " .. normal.z .. "\n"
	end
	return output
end
-- ========================================================================
-- generic helpers
-- ========================================================================

function wesh.out_of_bounds(pos)
	return pos.x < 1 or pos.x > 16
		or pos.y < 1 or pos.y > 16
		or pos.z < 1 or pos.z > 16
end

function wesh.check_plain(text)
	if type(text) ~= "string" then return "" end
	text = text:gsub("^[^%w]*(.-)[^%w]*$", "%1")
	return text:gsub("[^%w]+", "_"):lower()
end

function wesh.traverse_matrix(callback, ...)
	for x = 1, 16 do
		for y = 1, 16 do
			for z = 1, 16 do
				callback({x = x, y = y, z = z}, ...)
			end
		end
	end
end

function wesh.notify(player, message)
	local formspec = "size[10,5]textarea[1,1;8,3;notice;Notice;" .. minetest.formspec_escape(message) .. "]"
					.. "button_exit[6,4;3,0;exit;Okay]"
	local playername = player:get_player_name()
	minetest.show_formspec(playername, "notice_form", formspec)
	minetest.chat_send_player(playername, "[" .. wesh.name .. "] " .. message)
end

wesh._init()

