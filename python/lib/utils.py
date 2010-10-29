#!/usr/bin/env python2

# Piccolo richiamo a numpy:
# a = matrix( [[1, 3, 4], [1, 2, 3], [4, 3, 2]] )
# da la matrice quadrata

# a.T la trasposta
# a.I l'inversa

def pix_distance(a, b):
  """Defines the distance between two pixel.
  """
  from math import sqrt

  return sqrt((a[0] - b[0])**2 + (a[1] - b[1])**2 + (a[2] - b[2])**2)
