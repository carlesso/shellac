#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from utils import *

def get_center(original, border):
  #border = ImageDraw.Draw(original) #"L", (w, w), 255)
  borders = []

  w, h = original.size

  global data
  for i in xrange(0, w):
    diff = 0
    # XXX Hackone per la mancanza di "bordo" nella parte centrale dell'immagine
    if i > 750 and i < (750+600):
      continue
    for j in xrange(10, h, 1):
      diff = pix_distance(data[i, j], data[i, j-10])
      if diff > 90:
        # XXX Da valutare se è sensata come soglia
        # Threshold di distanza euclidea dei colori
        # We don't care if out of boundaries
        try:
          border.putpixel((i, j-1), 0)
          border.putpixel((i, j+1), 0)
        except:
          pass
        if j % 30:
          borders.append((i, j))
        # Coloro su border così da poterlo vedere dopo
        border.point((i, j), 256)
        print "Nella colonna", i, "ho lo stacco a", j
        break

  print borders
  print "I've ", len(borders), "points for boundary"

  # Genero le matrici per il calcolo del centro
  # Come da paper light-blue pagina 8
  H = matrix([[1, p[0], p[1]] for p in borders]) 
  h = matrix([[p[0]**2 + p[1]**2] for p in borders])
  a = (H.T*H).I*H.T*h

  # Calcolo le coordinate del centro e il raggio come da pagina 9
  # del medesimo paper
  x_c = a[1]/2
  y_c = a[2]/2
  r = sqrt(a[2] + x_c**2 + y_c**2)

  print "The center is in (%.3f, %.3f) with a radius of %.4f" % (x_c, y_c, r)

  # Lo disegno in border per controllare

  for i in range(5):
    for j in range(5):
      border.point((x_c - i, y_c - j), 0)
      border.point((x_c + i, y_c - j), 0)
      border.point((x_c - i, y_c + j), 0)
      border.point((x_c + i, y_c + j), 0)

  return x_c, y_c, r

