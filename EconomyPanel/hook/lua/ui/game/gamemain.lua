do
   local originalCreateUI = CreateUI

   function CreateUI(isReplay)
      originalCreateUI(isReplay)
      import("/mods/economypanel/economypanel.lua").Init()
   end
end
