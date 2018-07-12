import cv2
import numpy as np
import configs


def thresholdHSV(image):
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_hsv = np.array(
        [int(configs.HSV[0]), int(configs.HSV[1]), int(configs.HSV[2])])
    upper_hsv = np.array(
        [int(configs.HSV[3]), int(configs.HSV[4]), int(configs.HSV[5])])
    mask = cv2.inRange(hsv, lower_hsv, upper_hsv)
    mask = 255 - mask
    return(mask)


def removeMask(image, mask=np.array((0))):
    mask = thresholdHSV(image) if not mask.any() else mask
    return cv2.bitwise_and(image, image, mask=mask)


def getAreaMinRec(image):
    thresh = thresholdHSV(image)
    x, contours, hierarchy = cv2.findContours(thresh, 2, 1)
    bx = 0
    for n, x in enumerate(contours):
        bx = n if cv2.contourArea(x) > cv2.contourArea(contours[bx]) else bx
    cnt = contours[bx]
    rect = cv2.minAreaRect(cnt)
    box = cv2.boxPoints(rect)
    box = np.int0(box)
    return(cv2.contourArea(box))


def getAreaMinElipse(image):
    thresh = thresholdHSV(image)
    x, contours, hierarchy = cv2.findContours(thresh, 2, 1)
    bx = 0
    for n, x in enumerate(contours):
        bx = n if cv2.contourArea(x) > cv2.contourArea(contours[bx]) else bx
    cnt = contours[bx]
    ellipse = cv2.fitEllipse(cnt)
    return((ellipse[1][0] / 2) * (ellipse[1][1] / 2) * np.pi)


def getAreaMinCircle(image):
    thresh = thresholdHSV(image)
    x, contours, hierarchy = cv2.findContours(thresh, 2, 1)
    bx = 0
    for n, x in enumerate(contours):
        bx = n if cv2.contourArea(x) > cv2.contourArea(contours[bx]) else bx
    cnt = contours[bx]
    c, r = cv2.minEnclosingCircle(cnt)
    return(np.pi * r * r)


def calcAreaPercentage(image, total=1):
    image = removeMask(image)
    _, contours, hier = cv2.findContours(thresholdHSV(
        image), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    bx = 0
    for n, x in enumerate(contours):
        bx = n if cv2.contourArea(x) > cv2.contourArea(contours[bx]) else bx
    area = cv2.contourArea(contours[bx])
    return (area / total)


def distanciaMaiorDefeito(image):
    thresh = thresholdHSV(image)
    _, contours, hierarchy = cv2.findContours(thresh, 2, 1)
    bx = 0
    for n, x in enumerate(contours):
        bx = n if cv2.contourArea(x) > cv2.contourArea(contours[bx]) else bx
    cnt = contours[bx]
    hull = cv2.convexHull(cnt, returnPoints=False)
    defects = cv2.convexityDefects(cnt, hull)
    dm = 0
    for i in range(defects.shape[0]):
        d = defects[i, 0][-1]
        dm = d if d > dm else dm
        dm = 0 if i == 0 else dm
    return dm


def getValues(roi):
    values = []
    values.append(distanciaMaiorDefeito(roi))
    values.append(getAreaMinElipse(roi))
    values.append(getAreaMinRec(roi))
    values.append(getAreaMinCircle(roi))
    values.append(calcAreaPercentage(roi))
    return values


def separar(image):
    img = removeMask(image)
    img_th = thresholdHSVBorder(img)
    img = removeMask(img, img_th)
    # noise removal
    kernel = np.ones((1, 1), np.uint8)
    opening = cv2.morphologyEx(
        thresholdHSV(img),
        cv2.MORPH_OPEN,
        kernel,
        iterations=1)
    # sure background area
    sure_bg = cv2.dilate(opening, kernel, iterations=3)
    # Finding sure foreground area
    dist_transform = cv2.distanceTransform(opening, cv2.DIST_L2, 5)
    ret, sure_fg = cv2.threshold(
        dist_transform, 0.15 * dist_transform.max(), 255, 0)
    # Finding unknown region
    sure_fg = np.uint8(sure_fg)
    unknown = cv2.subtract(sure_bg, sure_fg)
    return unknown


def thresholdHSVBorder(image):
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    lower_hsv = np.array([
                         int(configs.Borda[0]),
                         int(configs.Borda[1]),
                         int(configs.Borda[2])
                         ])
    upper_hsv = np.array([
                         int(configs.Borda[3]),
                         int(configs.Borda[4]),
                         int(configs.Borda[5])
                         ])
    mask = cv2.inRange(hsv, lower_hsv, upper_hsv)
    mask = 255 - mask
    return(mask)


def getRois(path):
    imgs = cv2.imread(path)
    r = imgs.copy()
    separado = separar(imgs)
    rois = []
    _, contours, b = cv2.findContours(separado,
                                      cv2.RETR_EXTERNAL,
                                      cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        if(cv2.contourArea(cnt) > int(configs.Corte)):
            x, y, w, h = cv2.boundingRect(cnt)
            if(x - 10 > 0 and
               y - 10 > 0 and
               h + 10 < r.shape[:2][0] and
               w + 10 < r.shape[:2][1]):
                y -= 10
                x -= 10
                h += 10
                w += 10
            rois += [imgs[y:y + h, x:x + w]]
    return rois
