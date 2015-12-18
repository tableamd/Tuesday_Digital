#coding:utf-8

import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BOARD)
GPIO.setup(5, GPIO.OUT)

while 1:
    GPIO.output(5, True)
    sleep(1)
    GPIO.output(5, False)
    sleep(1)