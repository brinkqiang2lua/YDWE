local compiler = require "compiler"
local map_packer = require 'w3x2lni.map_packer'
local dev = fs.ydwe_devpath()

function event.EVENT_NEW_SAVE_MAP(event_data)
	log.debug("********************* on new save start *********************")

	-- 刷新配置数据
	global_config_reload()

	local map_path = fs.path(event_data.map_path)
	local temp_path = map_path:parent_path()
	local target_path = temp_path:parent_path() / map_path:filename()
	log.trace("Saving " .. target_path:string())

	-- 如果地图文件带有只读属性，则先询问是否去掉只读属性
	-- 128 == 0200 S_IWUSR
	if fs.exists(target_path) and 0 == (target_path:permissions() & 128) then		
		if gui.yesno_message(nil, LNG.REMOVE_MAP_READONLY, target_path:string()) then
			log.trace("Remove the read-only attribute.")
			target_path:add_permissions(128)
		else
            log.trace("Don't remove the read-only attribute.")
            log.debug("********************* on new save end *********************")
            return -1
		end
    end
    fs.remove(map_path)

    local result = compiler:compile(temp_path, global_config, war3_version:is_new() and 24 or 20)
    log.debug("Compiler Result " .. tostring(result))
    
    local result
    if map_path:filename():string() == '.w3x' then
        fs.copy_file(dev / 'plugin' / 'w3x2lni' / 'script' / 'core' / '.w3x', map_path, true)
        result = map_packer('lni', temp_path, target_path:parent_path())
    else
        result = map_packer('pack', temp_path, map_path)
        fs.create_directories(fs.ydwe_path() / 'backups')
        fs.copy_file(map_path, fs.ydwe_path() / 'backups' / map_path:filename(), true)
    end

	log.debug("Packer Result " .. tostring(result))
	log.debug("********************* on new save end *********************")
	if result then return 0 else return -1 end
end
