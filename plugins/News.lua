﻿function table.val_to_str(a)if"string"==type(a)then a=string.gsub(a,"\n","\\n")if string.match(string.gsub(a,"[^'\"]",""),'^"+$')then return"'"..a.."'"end;return'"'..string.gsub(a,'"','\\"')..'"'else return"table"==type(a)and table.tostring(a)or tostring(a)end end;function table.key_to_str(b)if"string"==type(b)and string.match(b,"^[_%a][_%a%d]*$")then return b else return"["..table.val_to_str(b).."]"end end;function table.tostring(c)local d,e={},{}for b,a in ipairs(c)do table.insert(d,table.val_to_str(a))e[b]=true end;for b,a in pairs(c)do if not e[b]then table.insert(d,table.key_to_str(b).."="..table.val_to_str(a))end end;return"{"..table.concat(d,",").."}"end

function Flooding(msg, matches)
  if matches[1]:lower() == "news" then
    local url = http.request('https://irapi.ir/sports/newspaper.php')
    local jdat = json:decode(url)
    local stt = table.tostring(jdat)
    stt = stt:gsub("{{","")
    stt = stt:gsub("}}","")
    stt = stt:gsub("},{","")
    stt = stt:gsub('"','')
    stt = stt:gsub("image=","")
    stt = stt:gsub("https","\nhttps")
    stt = stt:gsub("https","🔷🔶🔷🔶🔷🔶🔷🔶🔷\nhttps")
    stt = stt:gsub("{","")
    stt = stt:gsub("}","")
    local url , res = http.request('http://api.gpmod.ir/time/')
    if res ~= 200 then
     return reply_msg(msg.id, "❌ دوباره تلاش کنید !", ok_cb, false)
    end
    local jdat = json:decode(url)
    local text = "اخبار ورزشی روز <i>"..jdat.FAdate.." </i>:\n "..stt.." \n\n 🌐 @LINK_DONI_TM"
    return reply_msg(msg.id, text, ok_cb, false)
  end
end
return {
  patterns = {
    "^([Nn][Ee][Ww][Ss])$",
  },
  run = Flooding,
}
