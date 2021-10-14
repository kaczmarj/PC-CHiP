#!/usr/bin/python
from __future__ import division
import sys
import os
import cv2
import numpy as np
from PIL import Image
from openslide import OpenSlide


def getGradientMagnitude(im):
    "Get magnitude of gradient for given image"
    im=cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    ddepth = cv2.CV_32F
    dx = cv2.Sobel(im, ddepth, 1, 0)
    dy = cv2.Sobel(im, ddepth, 0, 1)
    dxabs = cv2.convertScaleAbs(dx)
    dyabs = cv2.convertScaleAbs(dy)
    mag = cv2.addWeighted(dxabs, 0.5, dyabs, 0.5, 0)
    return mag


def main():
    filepath=sys.argv[1]
    img  = OpenSlide(filepath)
    if not os.path.exists(sys.argv[3]):
        os.makedirs(sys.argv[3])
    if str(img.properties.values.__self__.get('tiff.ImageDescription')).split("|")[1] == "AppMag = 40":
        sz=1024
        seq=924
    else:
        sz=512
        seq=462
    [w, h] = img.dimensions
    for x in range(1, w, seq):
        for y in range(1, h, seq):
            print(str(x) + ", " + str(y))
            img1=img.read_region(location=(x,y), level=0, size=(sz,sz))
            img11=img1.convert("RGB")
            img111=img11.resize((512,512),Image.ANTIALIAS)
            grad=getGradientMagnitude(np.array(img111))
            unique, counts = np.unique(grad, return_counts=True)
            if counts[np.argwhere(unique<=20)].sum() < 512*512*0.6:
                img111.save(sys.argv[3] + "/" + sys.argv[2] + "_" +  str(x) + "_" + str(y) + '.jpg', 'JPEG', optimize=True, quality=94)

if __name__ == "__main__":
   main()
