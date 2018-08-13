local PlayerData = {}

function PlayerData:init()
	-- load XML data from file "test.xml" into local table xfile
	local xfile = xml.load("res/Data/test.xml")
	-- search for substatement having the tag "scene"
	local xscene = xfile:find("scene")
	-- if this substatement is found...
	if xscene ~= nil then
	  --  ...print it to screen
	  print(xscene)
	  --  print attribute id and first substatement
	  print( xscene.id, xscene[1] )
	  -- set attribute id
	  xscene["id"] = "newId"
	end
end