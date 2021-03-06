-------------------ModuleInfo-------------------
--- Author       : jx
--- Date         : 2020/02/15 23:45
--- Description  : 储存位置 旋转 缩放 父对象与子对象等数据
------------------------------------------------
---@class Transform : Component
local Transform, base = extends("Transform", Component)

function Transform:Constructor(gameObject, parent)
    --本地坐标
    self.m_position = Vector2.New()
    self.m_rotation = 0
    self.m_scale    = Vector2.New(1, 1)

    --图片大小
    self.m_size = Size.New(100, 100)
    --中心点
    self.m_pivot = Vector2.New(0.5, 0.5)

    --父对象
    self.parent = parent
    if not self.parent then
        SceneManager.GetRoot():Add(self)
    end
    --子对象列表
    self.m_childList = ArrayList.New()
end

---被销毁事件
function Transform:OnDestroy()
    ---销毁所有子物体
    for _, trans in ipairs(self.m_childList) do
        GameObject.Destroy(trans.gameObject)
    end
end

function Transform:__draw()
    for index, value in ipairs(self.m_childList) do
        value.gameObject:__draw()
    end
end
---设置与获取中心点
function Transform:SetPivot(value)
    if value.x < 0 then value.x = 0 end
    if value.x > 1 then value.x = 1 end
    if value.y < 0 then value.y = 0 end
    if value.y > 1 then value.y = 1 end
    self.m_pivot = value
end
function Transform:GetPivot()
    return self.m_pivot
end

---设置与获取图片大小
function Transform:SetSize(value)
    self.m_size = value
end
---@return Size 
function Transform:GetSize()
    return self.m_size
end

---前进的方向 过渡 Translation
function Transform:Translate(x, y)
    self.m_position.x = self.m_position.x + x
    self.m_position.y = self.m_position.y + y
end
---旋转角度
function Transform:Rotate(r)
    self.m_rotation = self.m_rotation + r
end


---设置父对象
---@param parent Transform 父对象
---@param isattrib boolean 属性是否重置，默认不重置
function Transform:SetParent(parent, isattrib)
    if self.parent then
        self.parent.m_childList:Remove(self)
    end
    --有父对象就设置父对象取消root，没父对象就设置为root
    if parent then
        self.parent = parent
        parent.m_childList:Add(self)
        --计算移动偏移
        if not isattrib then
            self.m_position = self.m_position - parent.m_position
            self.m_rotation = self.m_rotation - parent.m_rotation
            self.m_scale = self.m_scale / parent.m_scale
        end
        SceneManager.GetRoot():Remove(self)
    else
        SceneManager.GetRoot():Add(self)
    end
end

---设置相对位置
function Transform:SetLocalPosition(position)
    self.m_position = position
end
---获取相对位置
function Transform:GetLocalPosition()
    return self.m_position
end

---设置位置
function Transform:SetPosition(position, y)
    if y then
        position = Vector2.New(position, y)
    end
    self.m_position = self.WorldToLocal(self, position)
end

---@return Vector2 获取位置
function Transform:GetPosition()
    return self.LocalToWorld(self, 'position')
end

---设置相对旋转
function Transform:SetLocalRotation(rotation)
    self.m_rotation = rotation
end
---获取相对旋转
function Transform:GetLocalRotation()
    return self.m_rotation
end
---设置旋转
function Transform:SetRotation(rotation)
    self.m_rotation = self.WorldToLocal(self, rotation)
end
---获取旋转
function Transform:GetRotation()
    return self.LocalToWorld(self, 'rotation')
end


---设置相对缩放
function Transform:SetLocalScale(scale)
    self.m_scale = scale
end
---获取相对缩放
function Transform:GetLocalScale()
    return self.m_scale
end
---设置缩放
function Transform:SetScale(scale)
    self.m_scale = self.WorldToLocal(self, scale)
end
---获取缩放
function Transform:GetScale()
    return self.LocalToWorld(self, 'scale')
end

---获取所有子物体
function Transform:GetChildren()
    return self.m_childList
end
---按索引获取指定子物体
function Transform:GetChildAt(index)
    return self.m_childList:Get(index)
end
---按路径和名称获取子物体 如 root/hunman 就是获取root节点下的human节点
function Transform:GetChild(path)
    local arr = String.Split(path, ",")

    local trans = self
    for _, nodeName in ipairs(arr) do
        --临时记录当前transform，用来验证最后查找到了
        local tmp = trans
        for _, childTransf in ipairs(trans.m_childList) do
            if childTransf.gameObject.name == nodeName then
                trans = childTransf
                break
            end
        end
        assert(tmp ~= trans , "not found")
    end
    return trans
end

function Transform:ToString()
    return String.Format("{name: {0}, position: {1}, rotation: {2}, scale: {3}}",
           self.gameObject.name,
           self.m_position,
           self.m_rotation,
           self.m_scale )
end

----------------------------------static---------------------------------

function Transform.LocalToWorld(transform, attribType)
    local getParentPosition
    getParentPosition = function(transf)
        if transf.parent then
            if attribType == "position" then
                return transf.m_position + getParentPosition(transf.parent)
            elseif attribType == "rotation" then
                return transf.m_rotation + getParentPosition(transf.parent)
            elseif attribType == "scale" then
                return transf.m_scale * getParentPosition(transf.parent)
            end
        else
            if attribType == "position" then
                return transf.m_position
            elseif attribType == "rotation" then
                return transf.m_rotation
            elseif attribType == "scale" then
                return transf.m_scale
            end
        end
    end
    local result = getParentPosition(transform)
    return result
end

function Transform.WorldToLocal(transform, point)

    local getParentPosition
    getParentPosition = function(transf, point)
        if transf.parent then
            point = point - getParentPosition(transf.parent, point)
            return point
        else
            return point
        end
    end
    local result = getParentPosition(transform, point )
    return result
end


return Transform