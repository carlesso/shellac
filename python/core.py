#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from lib.utils import *
from lib.scan import Scan
from lib.shellac import Shellac

import os
import sys

if len(sys.argv) != 2:
  sys.stderr.write("Usage: %s image.png\n" % sys.argv[0])
  sys.exit(1)

image_path = sys.argv[1]

if not os.path.isfile(image_path):
  sys.stderr.write("Error: %s does not esists!\n" % sys.argv[1])
  sys.exit(1)


s = Shellac(image_path)

#s.get_center()
#s.draw_45()
#s.hystogram()
#s.unfold()
#s.show()
