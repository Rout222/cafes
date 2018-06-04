import lib
import cv2
from glob import glob
def nothing(x):
    pass
# Creating a window for later use
cv2.namedWindow('Result',cv2.WINDOW_NORMAL)
# Starting with 100's to prevent error while masking
limit = 1
# Creating track bar
config = open('config-corte.txt', "r").readlines()
config = config[0] if int(config[0]) else 0
paths = glob("./imagens/teste/*/*.jpg")
cv2.createTrackbar('limit', 'Result',int(config),2000,nothing)
cv2.createTrackbar('img', 'Result', 0, len(paths)-1,nothing)
cv2.createTrackbar('Threshold', 'Result', 0, 1,nothing)
while(1):
	imgs = cv2.imread(paths[cv2.getTrackbarPos('img','Result')])
	ts = lib.thresholdHSV(imgs)
	im = lib.removeMask(imgs)
	if(cv2.getTrackbarPos('Threshold', 'Result')):
		imgs = im
	_,contours,hierarchy = cv2.findContours(ts,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)
	limit = cv2.getTrackbarPos('limit','Result')
	for cnt in contours:
		if(cv2.contourArea(cnt) > cv2.getTrackbarPos('limit','Result')):
			x,y,w,h = cv2.boundingRect(cnt)
			roi=im[y-10:y+h+10,x-10:x+w+10]
			cv2.rectangle(imgs,(x-10,y-10),(x+w+10,y+h+10),(200,0,0),2)
	cv2.imshow('Result',imgs)
	k = cv2.waitKey(5) & 0xFF
cv2.destroyAllWindows()