#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import Image
import ImageDraw

from math import sqrt, pi, asin, cos, sin
from numpy import matrix, linalg

from utils import *
from border import *
from shape import Shape

class Scan:
  def __init__(self, file_path):
    self.file_path = file_path
    self.original_image = Image.open(file_path)
    self.original = self.original_image.convert("RGB")
    self.data = self.original.load()
    self.w, self.h = self.original.size
    return

  def show(self):
    self.original.show()
    return

  def get_center(self):
    self.borders = []
    self.border = ImageDraw.Draw(self.original) #"L", (w, w), 255)

    for i in xrange(0, self.w):
      diff = 0
      # XXX Hackone per la mancanza di "bordo" nella parte centrale dell'immagine
      if i > 750 and i < (750+600):
        continue
      for j in xrange(10, self.h, 1):
        diff = pix_distance(self.data[i, j], self.data[i, j-10])
        if diff > 90:
          # XXX Da valutare se è sensata come soglia
          # Threshold di distanza euclidea dei colori
          # We don't care if out of boundaries
          try:
            self.border.putpixel((i, j-1), 0)
            self.border.putpixel((i, j+1), 0)
          except:
            pass
          if j % 30:
            self.borders.append((i, j))
          # Coloro su border così da poterlo vedere dopo
          self.border.point((i, j), 256)
          print "Nella colonna", i, "ho lo stacco a", j
          break

    print self.borders
    print "I've ", len(self.borders), "points for boundary"

    self.shape = Shape(self.borders, self.w, self.h)

    # Lo disegno in border per controllare
    for i in range(5):
      for j in range(5):
        self.border.point((self.shape.center[0] - i, self.shape.center[1] - j), 0)
        self.border.point((self.shape.center[0] + i, self.shape.center[1] - j), 0)
        self.border.point((self.shape.center[0] - i, self.shape.center[1] + j), 0)
        self.border.point((self.shape.center[0] + i, self.shape.center[1] + j), 0)
    return

  def draw_45(self):
    self.shape.find_45()
    self.border.line([self.shape.center, self.shape.x_intersections[0]], fill=256)
    self.border.line([self.shape.center, self.shape.x_intersections[1]], fill=256)
    return

  def unfold(self):
    ro_max = self.h/2
    ro_min = ro_max/2
    theta_min = 3.0/4*pi
    theta_max = 1.0/4*pi
    theta_delta = theta_min - theta_max
    u_x, u_y = int(self.shape.diameter/4), int(ro_max - ro_min)
    self.unfolded_image = Image.new("RGB", (u_x, u_y))
    self.unfolded_image_data = self.unfolded_image.load()

    # Vadi a step pari alla lunghezza in pixel del quarto di diametro
    theta_steps = 1.0*(theta_min - theta_max) / u_x
    print "Theta steps are", theta_steps
    print "Theta max =", theta_max
    print "Theta min =", theta_min
    print "u_x and u_x are (%.3f, %.3f)" % (u_x, u_y)

    for x in xrange(u_x):
      #print "Fine ciclo", x
      for y in xrange(u_y):
        theta, ro = (theta_min - x*theta_steps, ro_max - y)
        cp_x, cp_y = (ro * cos(theta), ro * sin(theta))
        #print "(%d, %d) is mapped to (%.3f, %.3f) with ro, theta = (%.3f, %3f)" % (x, y, cp_x, cp_y, ro, theta)
        cp_x, cp_y = (cp_x + self.shape.center[0], self.shape.center[1] - cp_y)
        #print "(%d, %d) is mapped to (%.3f, %.3f) with ro, theta = (%.3f, %3f)" % (x, y, cp_x, cp_y, ro, theta)
        #raw_input("")
        try:
          self.unfolded_image_data[x, y] = self.data[int(cp_x), int(cp_y)]
        except:
          #print "ERRRORE"
          #print "(%d, %d) is mapped to (%.3f, %.3f) with ro, theta = (%.3f, %3f)" % (x, y, cp_x, cp_y, ro, theta)
          pass

    self.unfolded_image.save("unfolded.png")
    #self.unfolded_image.show()
    return
