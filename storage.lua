
-- silly mistake: I used to create a folder named afte the module
-- that conflicted with the file named in the same way created by get_mod_storage()
-- fix: if present, rename such folder as wesh.temp_foldername

local storage_folder = minetest.get_worldpath() .. "/mod_storage/"

local dirs = minetest.get_dir_list(storage_folder, true)

for _, dir in ipairs(dirs) do
	if dir == wesh.name then
		os.rename(storage_folder .. dir, storage_folder .. wesh.temp_foldername)
		break
	end
end

local storage = minetest.get_mod_storage()

return storage
