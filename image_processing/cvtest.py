# import cv2
# import numpy as np

# img = cv2.imread("img59585089.jpg",0)
# img = cv2.medianBlur(img,5)
# cimg = cv2.cvtColor(img,cv2.COLOR_GRAY2BGR)

# circles = cv2.HoughCircles(img,cv2.cv.CV_HOUGH_GRADIENT,1,20,
#                             param1=50,param2=30,minRadius=0,maxRadius=0)

# circles = np.uint16(np.around(circles))
# for i in circles[0,:]:
#     # draw the outer circle
#     cv2.circle(cimg,(i[0],i[1]),i[2],(0,255,0),2)
#     # draw the center of the circle
#     cv2.circle(cimg,(i[0],i[1]),2,(0,0,255),3)

# cv2.imshow('detected circles',cimg)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
import cv2

img = cv2.imread('test.png')
detector = cv2.FeatureDetector_create('ORB')
keypoints = detector.detect(img)
out = cv2.drawKeypoints(img, keypoints, None)
cv2.imshow("out", out)
cv2.waitKey(0)

# import cv2
 
# img = cv2.imread('Image1.png')
# gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
# sift = cv2.SIFT()
# keypoints = sift.detect(gray, None)
# img_with_keypoints = cv2.drawKeypoints(gray, keypoints)
# cv2.imshow("out", img_with_keypoints)
# cv2.waitKey(0)

