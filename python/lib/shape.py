#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from math import sqrt, pi
from numpy import matrix, linalg

class Shape:
  def __init__(self, borders, w, h):
    # Genero le matrici per il calcolo del centro
    # Come da paper light-blue pagina 8
    self.w, self.h = w, h
    self.H = matrix([[1, p[0], p[1]] for p in borders]) 
    self.h = matrix([[p[0]**2 + p[1]**2] for p in borders])
    self.a = (self.H.T*self.H).I*self.H.T*self.h

    # Calcolo le coordinate del centro e il raggio come da pagina 9
    # del medesimo paper
    x_c = self.a[1]/2
    y_c = self.a[2]/2
    r = sqrt(self.a[2] + x_c**2 + y_c**2)

    self.center = (x_c, y_c)
    self.radius = r
    self.diameter = 2*pi*self.radius

    print "The center is in (%.3f, %.3f) with a radius of %.4f" % (x_c, y_c, r)

  def find_45(self):
    """Finds the points of x_intersection.

    Given the center, draws two lines to spot the 45° lines.
    """
    self.q1 = self.center[0] - self.center[1]
    self.q2= self.center[0] + self.center[1]
    self.x_intersections = ((0, -self.q1), (self.q2, 0))
    return self.x_intersections
