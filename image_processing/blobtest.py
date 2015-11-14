#coding:utf-8

# Standard imports
import cv2
# import cv
import numpy as np
import sys
 
# Read image
im = cv2.imread(sys.argv[1], 1)

#グレイスケールを取得
img_gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)

#二値化をする。結果はimg_dstへ
thresh = 180
max_pixel = 255
ret, img_dst = cv2.threshold(img_gray,
                             thresh,
                             max_pixel,
                             cv2.THRESH_BINARY)

#白黒の反転を行う。必要な場合は用いる
#img_dst = (255-img_dst)
 
# Set up the detector with default parameters.
#detector = cv2.SimpleBlobDetector()

#フィルタリングに用いるパラメータを取得
params = cv2.SimpleBlobDetector_Params()
 
#フィルタの設定
params.filterByArea = True
params.minArea = 500
params.filterByConvexity = True
params.minConvexity = 0.5

#detectorを生成
ver = (cv2.__version__).split('.')
if int(ver[0]) < 3 :
    detector = cv2.SimpleBlobDetector(params)
else : 
    detector = cv2.SimpleBlobDetector_create(params)

 
#検知されたBLOBの座標を取得
keypoints = detector.detect(img_dst)

im_with_keypoints = cv2.drawKeypoints(img_dst, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

print len(keypoints)

# Show keypoints
cv2.imshow("Keypoints", im_with_keypoints)
cv2.waitKey(0)
