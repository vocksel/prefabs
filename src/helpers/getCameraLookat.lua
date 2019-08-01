-- Taken from the Animation Editor's rig builder. Modified to fit our needs.
local function getCameraLookat(maxRange)
    maxRange = maxRange or 20

    local camera = workspace.CurrentCamera

    if camera then
        local ray = Ray.new(camera.CFrame.p, camera.CFrame.lookVector * maxRange)
        local _, pos = workspace:FindPartOnRay(ray)
        camera.Focus = CFrame.new(pos)
        return pos
    else
        --Default position if they did weird stuff
        print("Unable to find default camera.")
        return Vector3.new(0,5.2,0)
    end
end

return getCameraLookat
