import wx
import wx.aui
import wx.lib.agw.thumbnailctrl as TC
import os  # usado no path do dirselect
from glob import glob
import cv2
import numpy as np
########################################################################


workinDir = os.getcwd()
globs = []


class WorkinDirectory(wx.Panel):
    def __init__(self, parent):
        """"""

        wx.Panel.__init__(self, parent=parent, id=wx.ID_ANY)

        self.dirselect = wx.DirPickerCtrl(self, id=wx.ID_ANY, path=workinDir)
        self.dirselect.Bind(wx.EVT_DIRPICKER_CHANGED, self.onChangeDir)
        self.thumbs = TC.ThumbnailCtrl(
            self, imagehandler=TC.NativeImageHandler)
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.dirselect, 0, wx.ALL, 5)
        sizer.Add(self.thumbs, 0, wx.EXPAND | wx.ALL, 5)
        self.thumbs.ShowDir(workinDir)

        self.SetSizer(sizer)

    def onChangeDir(self, event):

        global workinDir
        workinDir = self.dirselect.GetPath()

        self.thumbs.ShowDir(workinDir)


class ConfigHSV(wx.Panel):
    def __init__(self, *args, **kwds):
        # begin wxGlade: MyFrame.__init__
        kwds["style"] = kwds.get(
            "style", 0) | wx.DEFAULT_FRAME_STYLE | wx.ICONIZE | wx.MAXIMIZE | wx.MINIMIZE
        wx.Frame.__init__(self, *args, **kwds)
        self.panel_principal = wx.Panel(self, wx.ID_ANY)
        self.slider_imagens = wx.Slider(
            self.panel_principal, wx.ID_ANY, 0, 0, 1, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.h = wx.Slider(
            self.panel_principal, wx.ID_ANY, 0, 0, 179, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.s = wx.Slider(
            self.panel_principal, wx.ID_ANY, 0, 0, 179, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.v = wx.Slider(
            self.panel_principal, wx.ID_ANY, 0, 0, 255, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.h1 = wx.Slider(
            self.panel_principal, wx.ID_ANY, 179, 0, 255, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.s1 = wx.Slider(
            self.panel_principal, wx.ID_ANY, 68, 0, 255, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.v1 = wx.Slider(
            self.panel_principal, wx.ID_ANY, 166, 0, 255, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
        self.panel_2 = wx.Panel(self.panel_principal,
                                wx.ID_ANY, style=wx.FULL_REPAINT_ON_RESIZE)
        self.panel_3 = wx.Panel(self.panel_principal,
                                wx.ID_ANY, style=wx.FULL_REPAINT_ON_RESIZE)

        self.Bind(wx.EVT_SCROLL, self.slider_image_change)
        self.__do_layout()
        # end wxGlade

    def slider_image_change(self, event):
        id = self.slider_imagens.GetValue()
        self.genImage(id)
        self.thtest(id)

    def thtest(self, id):
        h = self.h.GetValue()
        s = self.s.GetValue()
        v = self.v.GetValue()
        h1 = self.h1.GetValue()
        s1 = self.s1.GetValue()
        v1 = self.v1.GetValue()
        img = cv2.imread(globs[id])
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        # Normal masking algorithm
        lower_blue = np.array([h, s, v])
        upper_blue = np.array([h1, s1, v1])

        mask = cv2.inRange(hsv, lower_blue, upper_blue)
        mask = 255 - mask
        cv2.imwrite("th_out.jpg", mask)
        image = wx.Image("th_out.jpg", wx.BITMAP_TYPE_ANY)
        W = image.GetWidth()
        H = image.GetHeight()
        maxW = self.sizerTh.GetSize()[0]
        maxH = self.sizerTh.GetSize()[1]
        if W > H:
            NewW = maxW
            NewH = maxH * H / W
        else:
            NewH = maxH
            NewW = maxW * W / H
        image = image.Scale(NewW, NewH)
        imageBitmap = wx.StaticBitmap(
            self.panel_2, wx.ID_ANY, wx.Bitmap(image))
        self.sizerTh.Add(imageBitmap, 1, wx.EXPAND)

    def genImage(self, id):
        image = wx.Image(globs[id], wx.BITMAP_TYPE_ANY)
        W = image.GetWidth()
        H = image.GetHeight()
        maxW = self.sizerOriginal.GetSize()[0]
        maxH = self.sizerOriginal.GetSize()[1]
        if W > H:
            NewW = maxW
            NewH = maxH * H / W
        else:
            NewH = maxH
            NewW = maxW * W / H
        image = image.Scale(NewW, NewH)
        imageBitmap = wx.StaticBitmap(self.panel_3, wx.ID_ANY, wx.Bitmap(image))
        self.sizerOriginal.Add(imageBitmap, 1, wx.EXPAND)

    def __do_layout(self):
        # begin wxGlade: MyFrame.__do_layout
        sizer_1 = wx.BoxSizer(wx.VERTICAL)
        grid_sizer_1 = wx.GridSizer(2, 2, 0, 0)
        self.sizerTh = wx.StaticBoxSizer(wx.StaticBox(
            self.panel_3, wx.ID_ANY, "ThreshHold"), wx.HORIZONTAL)
        self.sizerOriginal = wx.StaticBoxSizer(wx.StaticBox(
            self.panel_2, wx.ID_ANY, "Original"), wx.HORIZONTAL)
        sizer_2 = wx.StaticBoxSizer(wx.StaticBox(
            self.panel_principal, wx.ID_ANY, u"Configura\u00e7\u00f5es de HSV"), wx.VERTICAL)
        self.sizer_image = wx.StaticBoxSizer(wx.StaticBox(
            self.panel_principal, wx.ID_ANY, "Imagens"), wx.HORIZONTAL)
        self.sizer_image.Add(self.slider_imagens, 0, wx.EXPAND | wx.SHAPED, 0)
        grid_sizer_1.Add(self.sizer_image, 1, wx.EXPAND, 0)
        sizer_2.Add(self.h, 0, wx.EXPAND, 0)
        sizer_2.Add(self.s, 0, wx.EXPAND, 0)
        sizer_2.Add(self.v, 0, wx.EXPAND, 0)
        sizer_2.Add(self.h1, 0, wx.EXPAND, 0)
        sizer_2.Add(self.s1, 0, wx.EXPAND, 0)
        sizer_2.Add(self.v1, 0, wx.EXPAND, 0)
        grid_sizer_1.Add(sizer_2, 1, wx.EXPAND, 0)
        self.sizerOriginal.Add((0, 0), 0, 0, 0)
        self.panel_2.SetSizer(self.sizerOriginal)
        grid_sizer_1.Add(self.panel_2, 1, wx.ALL | wx.EXPAND, 0)
        self.sizerTh.Add((0, 0), 0, 0, 0)
        self.panel_3.SetSizer(self.sizerTh)
        grid_sizer_1.Add(self.panel_3, 1, wx.EXPAND, 0)
        self.panel_principal.SetSizer(grid_sizer_1)
        sizer_1.Add(self.panel_principal, 1, wx.EXPAND, 0)
        self.SetSizer(sizer_1)
        sizer_1.Fit(self)
        self.sizerOriginal.Fit(self)
        self.Layout()


class DemoPanel(wx.Panel):
    """
    This will be the first notebook tab
    """
    # ----------------------------------------------------------------------

    def __init__(self, parent):
        """"""
        wx.Panel.__init__(self, parent=parent, id=wx.ID_ANY)

        # create the AuiNotebook instance
        self.nb = wx.aui.AuiNotebook(self)

        # add some pages to the notebook
        pages = [(WorkinDirectory(self.nb), "Diretobrio de Trabalho"),
                 (ConfigHSV(self.nb), "Configurarcoes do OPENCV"),
                 (WorkinDirectory(self.nb), "Tab 3")]
        for page, label in pages:
            self.nb.AddPage(page, label)

        self.Bind(wx.aui.EVT_AUINOTEBOOK_PAGE_CHANGING, self.change)

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.nb, 1, wx.EXPAND)
        self.SetSizer(sizer)

    def change(self, event):
        global globs
        globs = glob(workinDir + "/*.jpg")
        if(self.nb.GetPageText(event.GetSelection()) == "Configurarcoes do OPENCV"):
            obj = self.nb.GetPage(event.GetSelection())
            obj.sizer_image.GetChildren()[0].DeleteWindows()
            if(len(globs) > 1):
                obj.sizer_image = wx.StaticBoxSizer(wx.StaticBox(
                    obj.panel_principal, wx.ID_ANY, "Imagens"), wx.HORIZONTAL)
                obj.slider_imagens = wx.Slider(obj.panel_principal, wx.ID_ANY, 0, 0, len(
                    globs) - 1, style=wx.SL_HORIZONTAL | wx.SL_LABELS)
                obj.sizer_image.Add(obj.slider_imagens, 0,
                                    wx.EXPAND | wx.SHAPED, 0)
            if(len(globs) >= 1):
                obj.genImage(0)


# #######################################################################


class DemoFrame(wx.Frame):
    """
    Frame that holds all other widgets
    """

    # ----------------------------------------------------------------------
    def __init__(self):
        """Constructor"""
        wx.Frame.__init__(self, None, wx.ID_ANY,
                          "Claassificação de cafés",
                          size=(600, 400))
        panel = DemoPanel(self)
        self.Show()


# ----------------------------------------------------------------------
if __name__ == "__main__":
    app = wx.App()
    frame = DemoFrame()
    app.MainLoop()
