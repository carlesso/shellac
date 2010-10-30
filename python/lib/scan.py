#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import Image
import ImageDraw

from math import sqrt
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
