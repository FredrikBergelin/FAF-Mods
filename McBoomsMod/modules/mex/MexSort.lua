function MexSortNormal(a, b)
    --function for sorting non-upgrading mexes
    return a:GetNumStorages() > b:GetNumStorages()
end

function MexSortUpgrading(a, b)
    --function for sorting upgrading mexes
    if a:GetNumStorages() > b:GetNumStorages() then
        return true
    end
    return a.unit:GetWorkProgress() > b.unit:GetWorkProgress()
end

function MexSortNaturalID(a, b)
    --function for sorting mexes on natural id
    return a:getNaturalID() < b:getNaturalID()
end