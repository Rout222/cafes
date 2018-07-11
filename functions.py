import wx
import cv2
import numpy as np


def genImage(path, w, h):
    print(BITMAP_TYPE_ANY)
    return 1
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
    return image


def threshold(path, width, height, h, s, v, h1, s1, v1):
    img = cv2.imread(path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # Normal masking algorithm
    lower_blue = np.array([h, s, v])
    upper_blue = np.array([h1, s1, v1])

    mask = cv2.inRange(hsv, lower_blue, upper_blue)
    mask = 255 - mask
    cv2.imwrite("output.jpg", mask)
    image = wx.Image("output.jpg", wx.BITMAP_TYPE_ANY)
    W = image.GetWidth()
    H = image.GetHeight()
    maxW = width
    maxH = height
    if W > H:
        NewW = maxW
        NewH = maxH * H / W
    else:
        NewH = maxH
        NewW = maxW * W / H
    image = image.Scale(NewW, NewH)
    return image
