import wx
import cv2
import numpy as np


def genImage(path, w, h):
    image = wx.Image(path, wx.BITMAP_TYPE_ANY)
    W = image.GetWidth()
    H = image.GetHeight()
    maxW = w
    maxH = h
    if W > H:
        NewW = maxW
        NewH = maxH * H / W
    else:
        NewH = maxH
        NewW = maxW * W / H
    image = image.Scale(NewW, NewH)
    return wx.Bitmap(image)


def threshold(path, **options):
    img = cv2.imread(path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    lower_blue = np.array([options['hsv'][0], options['hsv'][1], options['hsv'][2]])
    upper_blue = np.array([options['hsv'][3], options['hsv'][4], options['hsv'][5]])

    mask = cv2.inRange(hsv, lower_blue, upper_blue)
    mask = 255 - mask
    cv2.imwrite("output.jpg", mask)
    image = wx.Image("output.jpg", wx.BITMAP_TYPE_ANY)
    W = image.GetWidth()
    H = image.GetHeight()
    maxW = options['size'][0]
    maxH = options['size'][1]
    if W > H:
        NewW = maxW
        NewH = maxH * H / W
    else:
        NewH = maxH
        NewW = maxW * W / H
    image = image.Scale(NewW, NewH)
    return wx.Bitmap(image)
