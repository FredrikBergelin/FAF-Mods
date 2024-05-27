
-- We save first the original "ReceiveChatFromSim" function inside "OLDReceiveChatFromSim"
OLDReceiveChatFromSim = ReceiveChatFromSim
-- Now we are overwriting the original function with our own (hook)
function ReceiveChatFromSim(sender, msg)
    -- Here we are calling the original "ReceiveChatFromSim" function, so we don't break anything
    OLDReceiveChatFromSim(sender, msg)
    -- In case this is not a replay then...
    if not SessionIsReplay() then
        -- Store the message destination inside "SendTo"
        local SendTo = msg.to or 'all'

        -- if we send a message to "allies" then play the sound "UI_Diplomacy_Close"
        if SendTo == 'allies' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))

        -- if we send a message to "all" then play the sound "UI_Diplomacy_Close"
        elseif SendTo == 'all' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))

        -- if we send a private message then play the sound "UI_Diplomacy_Close"
        elseif SendTo == 'private' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))

        -- if we have a notify message then play the sound "UI_Diplomacy_Close"
        elseif SendTo == 'notify' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))

        -- if we can't identify the destinatin play the sound "UI_Diplomacy_Close"
        else -- same as 'all'
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))
        end

    end
end

-- List of all 116 possible sounds inside "Interface" sound bank:

-- X_Main_Menu_On
-- X_Main_Menu_Off
-- X_Main_Menu_On_Start
-- UI_Menu_Accept_01
-- UI_Menu_Cancel_02
-- UI_Menu_Error_01
-- UI_Menu_Select_01
-- UI_Skirmish_Map_Select
-- UI_Menu_Rollover
-- UI_Menu_MouseDown
-- UI_AEON_Rollover
-- UI_Back_MouseDown
-- UI_Cybran_Rollover
-- UI_Menu_MouseDown_Sml
-- UI_Menu_Rollover_Sml
-- UI_UEF_Rollover
-- UEF_Select_Vehicle
-- UEF_Select_Air
-- UEF_Select_Bot
-- UEF_Select_Factory
-- UEF_Select_Gun
-- UEF_Select_Naval
-- UEF_Select_Radar
-- UEF_Select_Resource
-- UEF_Select_Sonar
-- UEF_Select_Structure
-- UEF_Select_Sub
-- UEF_Select_Tank
-- Cybran_Select_Air
-- Cybran_Select_Bot
-- Cybran_Select_Factory
-- Cybran_Select_Gun
-- Cybran_Select_Naval
-- Cybran_Select_Radar
-- Cybran_Select_Resource
-- Cybran_Select_Sonar
-- Cybran_Select_Structure
-- Cybran_Select_Sub
-- Cybran_Select_Tank
-- Cybran_Select_Vehicle
-- Aeon_Select_Vehicle
-- Aeon_Select_Air
-- Aeon_Select_Bot
-- Aeon_Select_Factory
-- Aeon_Select_Gun
-- Aeon_Select_Naval
-- Aeon_Select_Radar
-- Aeon_Select_Resource
-- Aeon_Select_Sonar
-- Aeon_Select_Structure
-- Aeon_Select_Sub
-- Aeon_Select_Tank
-- UEF_Select_Commander
-- Cybran_Select_Commander
-- Aeon_Select_Commander
-- UI_Main_Window_Open 
-- UI_Objective_Window_Open
-- UI_Objective_Window_Close
-- UI_Objective_Description
-- UI_Objective_Checked
-- UI_Score_Window_Open
-- UI_Options_Rollover
-- UI_Mail_Window_Open
-- UI_Mail_Window_Close
-- UI_Diplomacy_Open
-- UI_Diplomacy_Close
-- UI_Action_Rollover
-- UI_Action_MouseDown
-- Cybran_Select_Spider
-- UI_Opt_Affirm_Over
-- UI_Opt_Menu_Top_Click
-- UI_Opt_Menu_Top_Over
-- UI_Opt_Mini_Button_Click
-- UI_Opt_Mini_Button_Over
-- UI_Opt_Yes_No
-- UI_Arrow_Click
-- UI_Comm_UEF_Out
-- UI_Comm_UEF_In
-- UI_Comm_CYB_Out
-- UI_Comm_CYB_In
-- UI_Comm_AEON_Out
-- UI_Comm_AEON_In
-- UI_Enhancements_Click
-- UI_Enhancements_Rollover
-- UI_Main_IG_Click
-- UI_Menu_Small_Over
-- UI_Objectives_Click
-- UI_Tab_Click_01
-- UI_Tab_Click_02
-- UI_Tab_Rollover_01
-- UI_Tab_Rollover_02
-- UI_Mod_Select
-- UI_Input_Error
-- UI_Economy_Rollover
-- UI_Economy_Click UI_Avatar_Hide
-- UI_Construct_Pause
-- UI_Construct_Infinite
-- UI_Tech_Level_Click
-- UI_Tech_Level_Rollover
-- UI_MFD_Click
-- UI_MFD_Rollover
-- UI_Mini_Rollover
-- UI_Mini_MouseDown
-- UI_Camera_Save_Position
-- UI_Camera_Recall_Position
-- UI_Camera_Delete_Position
-- UI_Comm_SER_In
-- UI_Comm_SER_Out
-- UI_Menu_MetalServo
-- UI_Menu_Ripper
-- UI_END_Game_Fail
-- UI_END_Game_Victory
-- UI_IG_Camera_Move
-- UI_MFD_checklist
-- UI_Announcement_Open
-- UI_Announcement_Close
