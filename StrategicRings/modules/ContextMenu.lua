local Group = import('/lua/maui/group.lua').Group
local UIUtil = import('/lua/ui/uiutil.lua')
local UIMain = import('/lua/ui/uimain.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local EscapeHandler = import('/lua/ui/dialogs/eschandler.lua')

ContextMenu = Class(Group) {
    __init = function(self, GUI, content, pos)
        Group.__init(self, GUI)
        self.content = content
        content:SetParent(self)
        LayoutHelpers.AtLeftTopIn(content, self)

        self.Width:Set(content.Width())
        self.Height:Set(content.Height())
        self.Depth:Set(GetFrame(GUI:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 10)

        local background = UIUtil.CreateNinePatchStd(self, '/scx_menu/lan-game-lobby/dialog/background/')
        LayoutHelpers.FillParentFixedBorder(background, content, 64)
        LayoutHelpers.DepthUnderParent(background, content)

        self:SetPosition(pos, GUI)
        self:RegisterMouseClickHandler()
        self:RegisterEscapeHandler()
    end,

    Close = function(self)
        self:OnClosed()
        self:Destroy()
    end,

    OnEscapePressed = function(self)
        self:Close()
    end,

    OnClosed = function(_)
        EscapeHandler.PopEscapeHandler()
    end,

    RegisterEscapeHandler = function(self)
        local this = self;

        EscapeHandler.PushEscapeHandler(function()
            EscapeHandler.PopEscapeHandler()
            this:OnEscapePressed()
        end)
    end,

    RegisterMouseClickHandler = function(self)
        local this = self

        function OnMouseClicked(event)
            if (event.x < this.Left() or event.x > this.Right()) or (event.y < this.Top() or event.y > this.Bottom()) then
                this:Close()
            end
        end

        UIMain.AddOnMouseClickedFunc(OnMouseClicked)
        this.OnDestroy = function(_)
            UIMain.RemoveOnMouseClickedFunc(OnMouseClicked)
        end
    end,

    SetPosition = function(self, pos, parent)
        if (pos.x + self.Width() <= parent.Width()) and (pos.y + self.Height() <= parent.Height()) then
            self.Left:Set(function() return pos.x end)
            self.Top:Set(function() return pos.y end)
        elseif (pos.x + self.Width() < parent.Width()) and (pos.y + self.Height() > parent.Height()) then
            self.Left:Set(function() return pos.x end)
            self.Top:Set(function() return pos.y - self.Height() end)
        elseif (pos.x + self.content.Width() > parent.Width()) and (pos.y + self.Height() < parent.Height()) then
            self.Left:Set(function() return pos.x - self.Width() end)
            self.Top:Set(function() return pos.y end)
        elseif (pos.x + self.content.Width() > parent.Width()) and (pos.y + self.Height() > parent.Height()) then
            self.Left:Set(function() return pos.x - self.Width() end)
            self.Top:Set(function() return pos.y - self.Height() end)
        else
            self.Left:Set(function() return 0 end)
            self.Top:Set(function() return 0 end)
        end
    end
}
