do
   local originalCreateUI = CreateUI

   function CreateUI(isReplay)
      originalCreateUI(isReplay)
      import("/mods/AutoPause/economypanel.lua").Init()
   end
end
