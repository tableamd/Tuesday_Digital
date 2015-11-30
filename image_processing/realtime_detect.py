#coding:utf-8

import numpy as np
import cv2
import sys

fontface = cv2.FONT_HERSHEY_PLAIN
fontscale = 5
thresh = 180
max_pixel = 255
count = 0

#img_dst = (255-img_dst)
#フィルタリングに用いるパラメータを取得
params = cv2.SimpleBlobDetector_Params()
#フィルタの設定
params.filterByArea = True
params.minArea = 100
params.filterByConvexity = True
params.minConvexity = 0.5
#detectorを生成
ver = (cv2.__version__).split('.')
if int(ver[0]) < 3 :
    detector = cv2.SimpleBlobDetector(params)
else : 
    detector = cv2.SimpleBlobDetector_create(params)
cap = cv2.VideoCapture(0)

while True:
    ret, img = cap.read()
    img_src = cv2.resize(img, (800, 600))

    #グレースケール
    img_gray = cv2.cvtColor(img_src, cv2.COLOR_BGR2GRAY)
    #ガウスフィルタ
    im_gray_smooth = cv2.GaussianBlur(img_gray,(11,11),0)
    ret, img_dst = cv2.threshold(im_gray_smooth,
                                 thresh,
                                 max_pixel,
                                 cv2.THRESH_BINARY)
    #img_dst = (255-img_dst)
    #検知されたBLOBの座標を取得
    keypoints = detector.detect(img_dst)
    im_with_keypoints = cv2.drawKeypoints(img_dst, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
    #輪郭検出 RETR_EXTERNAL:最外殻 RETR_TREE:それぞれの部分
    c, h = cv2.findContours( img_dst, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE )
    for t in c:
        x,y,w,h = cv2.boundingRect(t)
        cv2.rectangle(im_with_keypoints,(x,y),(x+w,y+h),(255,0,0),2)
        for k in keypoints:
            if (x < k.pt[0] < x+w) and (y < k.pt[1] < y+h):
                count += 1
        cv2.putText(im_with_keypoints,str(count),(x+w-10,y+h-10),fontface,fontscale,(255,255,255)) 
        count = 0

    cv2.imshow('camera capture', im_with_keypoints)

    k = cv2.waitKey(1) # 1msec待つ
    if k == 27: # ESCキーで終了
        break

cap.release()
cv2.destroyAllWindows()
