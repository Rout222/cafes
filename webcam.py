import classificacao
import lib
import cv2
from glob import glob
# imagens = glob('./cafe/*.JPG')
imagens = glob('./cafe/*.JPG')
config = open('config_corte.txt', "r").readlines()
cv2.namedWindow('Result',cv2.WINDOW_NORMAL)
config = config[0] if int(config[0]) else 0
cases = {1.0 : [0,255,0], 0. : [120,170,50], -1.: [0,0,255]}
idx=0
for i in imagens:
	imgs = cv2.imread(i)
	r = imgs.copy()
	separado = lib.separar(imgs)
	im = lib.removeMask(imgs)
	_,contours,b = cv2.findContours(separado,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
	limit = cv2.getTrackbarPos('limit','Result')
	for cnt in contours:
		if(cv2.contourArea(cnt) > int(config)):
			idx += 1
			x,y,w,h = cv2.boundingRect(cnt)
			if(x-10 > 0 and y-10 > 0 and h+10 < r.shape[:2][0] and w+10 < r.shape[:2][1]):
				y -= 10
				x -= 10
				h += 10
				w += 10
			roi=imgs[y:y+h,x:x+w]
			color = cases[classificacao.predictSingleImage(roi)]
			cv2.drawContours(r, [cnt], -1, color, 2, cv2.LINE_AA)
	cv2.imshow("Result", r)
	cv2.waitKey(0)
