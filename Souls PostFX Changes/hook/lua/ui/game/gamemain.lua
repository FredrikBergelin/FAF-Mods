
do
	local CameraModSettings = import ('/mods/Souls PostFX Changes/settings.lua').SCMSettings
	local SCMCameraChangeSetting = CameraModSettings.CameraChangeSetting
	local SCMShadowQuality = CameraModSettings.ShadowQuality
	local SCMCameraShake = CameraModSettings.CameraShake
	local SCMBloomIntensity = CameraModSettings.BloomIntensity
	local SCMFreecamFix = CameraModSettings.FreecamFix
	
	if SCMCameraChangeSetting == 0 then -- Off
	else
		if SCMCameraChangeSetting == 1 then -- Souls 'Modern'
				ConExecute("cam_FarFOV = 90")
				ConExecute("cam_NearFOV = 110")
				ConExecute("cam_NearPitch = 20")
				ConExecute("cam_NearZoom = 20")
				ConExecute("cam_FarPitch = 90")
		else 
			if SCMCameraChangeSetting == 2 then -- TopDown
					ConExecute("cam_FarFOV = 110")
					ConExecute("cam_NearFOV = 20")
					ConExecute("cam_NearPitch = 90")
					ConExecute("cam_NearZoom = 1")
					ConExecute("cam_FarPitch = 90")
			else 
				if SCMCameraChangeSetting == 3 then -- Ortho Perspective
						ConExecute("cam_FarFOV = 1")
						ConExecute("cam_NearFOV = 1")
						ConExecute("cam_NearPitch = 45")
						ConExecute("cam_NearZoom = 1")
						ConExecute("cam_FarPitch = 90")
				end
			end
		end
	end
	
	if SCMShadowQuality == 0 then -- Off
	else
		if SCMShadowQuality == 1 then -- Low
				ConExecute("ren_shadowblur 0")
				ConExecute("ren_shadowsize 256")
		else 
			if SCMShadowQuality == 2 then -- Medium
					ConExecute("ren_shadowblur 0")
					ConExecute("ren_shadowsize 1024")
			else 
				if SCMShadowQuality == 3 then -- High (Default)
						ConExecute("ren_shadowblur 0")
						ConExecute("ren_shadowsize 2048")
				else 
					if SCMShadowQuality == 4 then -- Ultra
							ConExecute("ren_shadowblur 0")
							ConExecute("ren_shadowsize 4096")
					end
				end
			end
		end
	end
	
	if SCMCameraShake == 0 then -- Off
		ConExecute("cam_ShakeMult 0")
	else
		if SCMCameraShake == 1 then -- Little (Default)
				ConExecute("cam_ShakeMult 0.3")
		else 
			if SCMCameraShake == 2 then -- Less
					ConExecute("cam_ShakeMult 0.6")
			else 
				if SCMCameraShake == 3 then -- Vanilla
						ConExecute("cam_ShakeMult 1")
				else 
					if SCMCameraShake == 4 then -- More
							ConExecute("cam_ShakeMult 1.5")
					end
				end
			end
		end
	end

	if SCMBloomIntensity == 0 then -- Off
		ConExecute("ren_bloom 0")
	else
		if SCMBloomIntensity == 1 then -- Little (Default)
				ConExecute("ren_bloom 1")
				ConExecute("ren_BloomBlurKernelScale = 1.2")
				ConExecute("ren_BloomGlowCopyScale = 0.8")
		else 
			if SCMBloomIntensity == 2 then -- Less
					ConExecute("ren_bloom 1")
					ConExecute("ren_BloomBlurKernelScale = 1.4")
					ConExecute("ren_BloomGlowCopyScale = 1.2")
			else 
				if SCMBloomIntensity == 3 then -- Vanilla
						ConExecute("ren_bloom 1")
						ConExecute("ren_BloomBlurKernelScale = 1.5")
						ConExecute("ren_BloomGlowCopyScale = 1.5")
				else 
					if SCMBloomIntensity == 4 then -- More
							ConExecute("ren_bloom 1")
							ConExecute("ren_BloomBlurKernelScale = 1.8")
							ConExecute("ren_BloomGlowCopyScale = 2")
					end
				end
			end
		end
	end
	
	if SCMFreecamFix == 1 then
		ConExecute("cam_MinSpinPitch = 0")
	end
	
	--[[
	-- camera stuff
	ConExecute("cam_FarFOV = 90")
	ConExecute("cam_NearFOV = 110")
	ConExecute("cam_NearPitch = 20")
	ConExecute("cam_NearZoom = 20")
	ConExecute("cam_FarPitch = 90")
	ConExecute("cam_MinSpinPitch = 0")
	-- ConExecute("cam_Free")

	-- shadow stuff
	ConExecute("ren_shadowblur 0")
	ConExecute("ren_shadowsize 2048")
	
	-- postfx stuff
	ConExecute("ren_bloom 1")
	ConExecute("cam_ShakeMult 0.3")
	ConExecute("ren_BloomBlurKernelScale = 1.2")
	ConExecute("ren_BloomGlowCopyScale = 0.8")
	]]
end

