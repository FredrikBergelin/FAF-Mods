do
   local originalCreateUI = CreateUI

   function CreateUI(isReplay)
      originalCreateUI(isReplay)
      import("/mods/AutoPause/AutoPause.lua").Init()
   end
end
