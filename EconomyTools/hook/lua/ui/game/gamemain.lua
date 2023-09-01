do
   local originalCreateUI = CreateUI

   function CreateUI(isReplay)
      originalCreateUI(isReplay)
      -- import("/mods/EconomyTools/main.lua").Init()
   end
end
