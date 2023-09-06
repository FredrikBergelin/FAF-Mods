--For changing game speed by given amount
function ChangeSimRate(rate)
    ConExecute("WLD_GameSpeed " .. (GetSimRate() + rate))
end




