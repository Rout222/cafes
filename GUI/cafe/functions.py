import wx
import cv2
import numpy as np
import functionsCV

# para o gauge em thread
from threading import Thread
from wx.lib.pubsub import pub
import csv


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

    lower_blue = np.array(
        [options['hsv'][0], options['hsv'][1], options['hsv'][2]])
    upper_blue = np.array(
        [options['hsv'][3], options['hsv'][4], options['hsv'][5]])

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


def makeClass(paths, separator):
    Classes = {}
    for photo in paths:
        text = photo.split("\\")[-1].split(".")
        if(len(separator) > 0):
            text = text[0].split(separator)
        if(len(text) == 1):
            if('Sem classe' in Classes):
                Classes['Sem_classe'] += 1
            else:
                Classes['Sem_classe'] = 1
        else:
            if(text[1] in Classes):
                Classes[text[1]] += 1
            else:
                Classes[text[1]] = 1
    return Classes


def getClass(path, separator):
    text = path.split("\\")[-1].split(".")[0].split(separator)
    if(len(text) == 1):
        return "Sem_Classe"
    else:
        return text[1]


class OutputThread(Thread):

    def __init__(self, paths, separator, outputFile="output.txt"):
        Thread.__init__(self)
        self.paths = paths
        self.separator = separator
        self.outputFile = outputFile
        self.start()

    def run(self):
        resultado = []
        for path in self.paths:
            classe = getClass(path, self.separator)  # classe da imagem toda
            for roi in functionsCV.getRois(path):
                resultado += [functionsCV.getValues(roi) + [classe]]
            wx.CallAfter(pub.sendMessage, "update", msg="")
        cabecalho = ['convexHull', 'Elipse',
                     'Rec', 'Circle', 'Area',
                     'Classe']
        with open(self.outputFile, 'w', newline='') as resultFile:
            wr = csv.writer(resultFile, dialect='excel')
            wr.writerow(cabecalho)
            for item in resultado:
                wr.writerow(item)
        wx.CallAfter(pub.sendMessage, "update", msg="")
