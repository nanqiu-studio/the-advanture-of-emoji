-------------------ModuleInfo-------------------
--- Author       : jx
--- Date         : 2020/02/17 16:55
--- Description  : 摄像机
------------------------------------------------
---@class Camera : Component
local Camera, base = extends("Camera", Component)

function Camera:Constructor()
    self.m_backgroundColor = Color.Black
end

--渲染流程
--新建与设置主摄像机 
--引擎底层通知场景管理器渲染 
--场景管理器通知当前场景渲染
--当前场景渲染所有组件和子物体的组件
--Image通过调用Camera进行渲染，Camera获取当前场景的当前相机进行调用
--通过Camera直接渲染，但是内部是获取当前场景的当前摄像机进行渲染

--渲染图片
function Camera.RenderImage(image)
    local cam = SceneManager.GetCurrentScene():GetCurrentCamera()
    cam:__renderImage(image)
end


function Camera:OnEnable()

end

function Camera:OnDisable()
    
end

---@param color Color
function Camera:SetBackgroundColor(color)
    self.m_backgroundColor = color
end
function Camera:GetBackgroundColor()
    return self.m_backgroundColor
end


local function distance(x1, y1, x2, y2)
    local x = math.abs(x1 - x2)
    local y = math.abs(y1 - y2)
    return math.sqrt((x * x + y * y))
end

--渲染image组件
---@param image Image
function Camera:__renderImage(image)
    local transform = image.transform
    local sprite = image:GetSprite()
    local transPosition = transform:GetPosition()
    local transSize = transform:GetSize()
    local transPivot = transform:GetPivot()
    --半径 = 中心点离左上角点的距离
    local luX = transPosition.x - transSize.width * transPivot.x
    local luY = transPosition.y - transSize.height * transPivot.y
    local radius = distance(transPosition.x, transPosition.y, luX, luY)

    local x = transPosition.x
    local y = transPosition.y

    local rotation = transform:GetRotation() 
    local scale    = transform:GetScale()

    x = x + radius * math.cos(math.rad(rotation - 90 - 45))
    y = y + radius * math.sin(math.rad(rotation - 90 - 45))

    IEngine.SetBackgroundColor(self.m_backgroundColor)
    IEngine.DrawImage(sprite, x, y, rotation, transSize.width, transSize.height)
end

--设置为主摄像机
function Camera:SetMainCamera()
    SceneManager.SetCurrentCamera(self)
end


return Camera