# -*- coding: utf8 -*-

import sys

import cv
import datetime

from numpy import matrix
from math import sqrt, pi, sin, cos

class Shellac:
  def __init__(self, path):
    self.image = cv.LoadImage(path, 0)
    self.canny = cv.CreateImage(cv.GetSize(self.image), 8, 1)
    #self.canny = cv.CreateMat(self.image.width, self.image.height, 5)
    self.result = cv.CreateImage((self.canny.width, self.canny.height), 8, 1)

    self.window = cv.NamedWindow("Shellac");
    c = cv.Canny(self.image, self.canny, 400, 620)
    #seq = cv.FindContours(self.image, cv.CreateMemStorage(), cv.CV_RETR_TREE, cv.CV_CHAIN_APPROX_SIMPLE)
    #c = cv.CornerEigenValsAndVecs(self.image, self.canny, 255)
    #c = cv.CornerHarris(self.image, self.canny, 4)
    #cv.SetImageROI(self.result, cv.Rectangle(0, 0, self.canny.width, self.canny.height))
    #cv.Copy(canny, result)
    # print self.canny[0]
    # print self.canny[2047]
    # print self.canny.width
    # print self.canny.height
    # print len(self.canny.tostring())
    self.center_detection()
    # self.extrapolate_line()
    self.unfold(0.1, 0.5)
    #self.show(self.canny)

  def extrapolate_line(self, step = 0):
    self.line = cv.CreateImage((1, self.radius), 8, 1)

    theta_min = 3.0/4*pi
    theta_max = 1.0/4*pi
    theta_delta = theta_min - theta_max

    theta_steps = 1.0 * (theta_delta) / self.myborder

    self.histogram = cv.CreateImage((self.radius, 255), 8, 1)
    
    if step < 0 or step > self.myborder:
      sys.stderr.write("Step required is out of boundaries! Must be > 0 and < %d, got % instead\n" % (self.myborders, step))
      sys.exit(1)

    for y in xrange(self.radius):
      theta, ro = (theta_min / 2 - theta_max / 2, self.radius - y)
      cp_x, cp_y = (ro * cos(theta), ro * sin(theta))
      cp_x, cp_y = (cp_x + self.center[0], self.center[1] - cp_y)
      try:
        # XXX Si può verificare int, floor, ceil per vedere qualità
        value = self.image[int(cp_y), int(cp_x)]
        self.line[y, 0] = value
        self.histogram[value, y] = 255
        pass
      except Exception, e:
        print "Sono andato fuori!", e

    self.show(self.histogram)


  def unfold(self, top = 0, bottom = 0):

    _top = int(self.radius * (1.0 - top))
    _bottom = int(self.radius * bottom)
    print "Limo via da %f a %f" % (top, bottom)
    print "La dimensione mi viene %d" % (_top - _bottom)
    print "Andando da %d a %d" % (_bottom, _top)
    raw_input()

    self.unfolded = cv.CreateImage((_top - _bottom, self.radius), 8, 1)
    
    theta_min = 3.0/4*pi
    theta_max = 1.0/4*pi
    theta_delta = theta_min - theta_max

    theta_steps = 1.0 * (theta_delta) / self.myborder

    
    # XXX Qui si spacca tutto per le dimensioni dell'immagine 2010-11-04
    for x in xrange(self.myborder):
      print "On row %d/%d" % (x, self.myborder)
      for y in xrange(_bottom, _top):
        theta, ro = (theta_min - x*theta_steps, self.radius - y)
        cp_x, cp_y = (ro * cos(theta), ro * sin(theta))
        cp_x, cp_y = (cp_x + self.center[0], self.center[1] - cp_y)
        try:
          # XXX Si può verificare int, floor, ceil per vedere qualità
          self.unfolded[y - _bottom, y] = self.image[int(cp_y), int(cp_x)]
        except Exception, e:
          print "Sono andato fuori!", e
    
    self.show(self.unfolded)


  def center_detection(self):
    w = self.canny.width
    self.borders = []
    for i in xrange(int(w*.05), int(w*.33)):
      try:
        self.borders.append((i, self.canny[i].tostring().index(chr(255))))
      except ValueError:
        pass
    for i in xrange(int(w*.66), int(w*.95)):
      try:
        self.borders.append((i, self.canny[i].tostring().index(chr(255))))
      except ValueError:
        pass
    self.get_center()

  def get_center(self):
    self.H = matrix([[1, p[0], p[1]] for p in self.borders])
    self.h = matrix([[p[0]**2 + p[1]**2] for p in self.borders])
    self.a = (self.H.T*self.H).I*self.H.T*self.h

    # Calcolo le coordinate del centro e il raggio come da pagina 9
    # del medesimo paper
    x_c = self.a[1]/2
    y_c = self.a[2]/2
    r = sqrt(self.a[2] + x_c**2 + y_c**2)
    
    
    self.center_f = (x_c, y_c)
    self.center = (int(x_c), int(y_c))
    self.radius_f = r
    self.radius = int(r)
    self.diameter_f = 2*pi*self.radius
    self.diameter = int(2*pi*self.radius)
    # Stores the size we want to work with
    self.myborder_f = 2*pi*self.radius
    self.myborder = int(2*pi*self.radius)

    print "The center is in (%.3f, %.3f) with a radius of %.4f" % (x_c, y_c, r)
  
    

  def show(self, what):
    cv.ShowImage("Shellac", what)
    key = None
    while key not in [113, 1048689]:
      key = cv.WaitKey()
      if key in [115, 1048691]:
        fname = datetime.datetime.now().strftime("out/shellac %Y-%m-%d %H:%M.jpg")
        print "Saving image to %s" % fname
        cv.SaveImage(fname, what)
    return
