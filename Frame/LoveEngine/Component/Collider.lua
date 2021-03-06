-------------------ModuleInfo-------------------
--- Author       : jx
--- Date         : 2020/02/16 23:01:57
--- Description  : 碰撞抽象类
------------------------------------------------
---@class Collider : Component
local Collider, base = extends("Collider", Component)

function Collider:Constructor()
    self.m_layer = nil
    self.m_isTrigger = false
end
---启用事件
function Collider:OnEnable()
    SceneManager.__addSceneColliderInfo(self)
end

---禁用事件
function Collider:OnDisable()
    SceneManager.__removeSceneColliderInfo(self)
end

---第一次运行事件
function Collider:Start()

end

---帧更新事件
function Collider:Update(dt)

end

---销毁事件
function Collider:OnDestroy()

end

---绘图事件
function Collider:__draw()

end



return Collider