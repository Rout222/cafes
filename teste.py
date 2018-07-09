import wx
import wx.lib.agw.labelbook as LB

class MyFrame(wx.Frame):

    def __init__(self, parent):

        wx.Frame.__init__(self, parent, -1, "LabelBook Demo")

        # Possible values for Tab placement are INB_TOP, INB_BOTTOM, INB_RIGHT, INB_LEFT

        notebook = LB.LabelBook(self, -1, agwStyle=LB.INB_FIT_LABELTEXT|LB.INB_LEFT|LB.INB_DRAW_SHADOW|LB.INB_GRADIENT_BACKGROUND)

        pane1 = wx.Panel(notebook)
        pane2 = wx.Panel(notebook)

        imagelist = wx.ImageList(32, 32)
        imagelist.Add(wx.Bitmap("output.jpg", wx.BITMAP_TYPE_ANY))
        notebook.AssignImageList(imagelist)
            
        notebook.AddPage(pane1, "Tab1", 1, 0)
        notebook.AddPage(pane2, "Tab2", 0, 0)


# our normal wxApp-derived class, as usual

app = wx.App(0)

frame = MyFrame(None)
app.SetTopWindow(frame)
frame.Show()

app.MainLoop()