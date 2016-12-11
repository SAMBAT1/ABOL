do

-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_all_plugins(only_enabled)
  local tmp = ''
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    --  ☑️ enabled, 🔘 disabled
    local status = '🔘'
    nsum = nsum+1
    nact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '☑️' 
      end
      nact = nact+1
    end
    if not only_enabled or status == '☑️' then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      text = text..nsum..'.'..status..' '..v..' \n'
    end
  end
  local text = text..'\n\n'..nsum..' plugins installed\n\n'..nact..' plugins enabled\n\n'..nsum-nact..' plugins disabled'..tmp
  return text
end

local function list_plugins(only_enabled)
  local text = ''
  local nsum = 0
  for k, v in pairs( plugins_names( )) do
    --  ☑️ enabled, 🔘 disabled
    local status = '🔘'
    nsum = nsum+1
    nact = 0
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '☑️' 
      end
      nact = nact+1
    end
    if not only_enabled or status == '☑️' then
      -- get the name
      v = string.match (v, "(.*)%.lua")
     -- text = text..v..'  '..status..'\n'
    end
  end
  local text = text..'<i> تغییرات مورد نظر شما اعمال گردید! </i>'
  return text
end

local function reload_plugins( )
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')
  -- Check if plugin is enabled
  if plugin_enabled(plugin_name) then
    return 'افزونه [<b>'..plugin_name..'</b>] فعال است'
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    -- Reload the plugins
    return reload_plugins( )
  else
    return 'افزونه [<b>'..plugin_name..'</b>] یافت نشد'
  end
end

local function disable_plugin( name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return 'افزونه [<b>'..name..'</b>] یافت نشد'
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return 'افزونه [<b>'..name..'</b>] فعال نیست'
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return "<i> افزونه مورد نظر یافت نشد </i>"
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return '<i> افزونه </i> [<b>'..plugin..'</b>] <i> در این گروه غیر فعال شد </i>'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'There aren\'t any disabled plugins'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return 'There aren\'t any disabled plugins for this chat'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return 'این افزونه در این گروه غیرفعال نیست'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return '<i> افزونه </i> [<b>'..plugin..'</b>] <i> مجدد فعال شد </i>'
end

local function run(msg, matches)
  -- Show the available plugins 
  if matches[1] == '/plug' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return list_all_plugins()
  end

  -- Re-enable a plugin for this chat
  if matches[1] == '+' and matches[3] == 'chat' then
      if is_owner(msg) then
    local receiver = get_receiver(msg)
    local plugin = matches[2]
    print("enable "..plugin..' on this chat')
    return reenable_plugin_on_chat(receiver, plugin)
  end
    end

  -- Enable a plugin
  if matches[1] == '+' and is_sudo(msg) then --after changed to moderator mode, set only sudo
      if is_owner(msg) then
    local plugin_name = matches[2]
    print("enable: "..matches[2])
    return enable_plugin(plugin_name)
  end
    end
  -- Disable a plugin on a chat
  if matches[1] == '-' and matches[3] == 'chat' and is_owner(msg) then
      if is_owner(msg) then
    local plugin = matches[2]
    local receiver = get_receiver(msg)
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(receiver, plugin)
  end
    end
  -- Disable a plugin
  if matches[1] == '-' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    if matches[2] == 'plugins' then
    	return 'این افزونه نمی تواند غیر فعال شود'
    end
    print("disable: "..matches[2])
    return disable_plugin(matches[2])
  end

  -- Reload all the plugins!
  if matches[1] == '*' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return reload_plugins(true)
  end
  if matches[1] == 'reload' and is_sudo(msg) then --after changed to moderator mode, set only sudo
    return reload_plugins(true)
  end
end

return {
  description = "Plugin to manage other plugins. Enable, disable or reload.", 
  usage = {
      moderator = {
          "/plug disable [plugin] chat : disable plugin only this chat.",
          "/plug enable [plugin] chat : enable plugin only this chat.",
          },
      sudo = {
          "/plug : list all plugins.",
          "/plug + [plugin] : enable plugin.",
          "/plug - [plugin] : disable plugin.",
          "/plug * : reloads all plugins." },
          },
  patterns = {
    "^/plug$",
    "^/plug? (+) ([%w_%.%-]+)$",
    "^/plug? (-) ([%w_%.%-]+)$",
    "^/plug? (+) ([%w_%.%-]+) (chat)",
    "^/plug? (-) ([%w_%.%-]+) (chat)",
    "^/plug? (*)$",
    },
  run = run,
  moderated = true, -- set to moderator mode
  --privileged = true
}

end