import cv
import datetime

class Shellac:
  def __init__(self, path):
    self.image = cv.LoadImage(path, 0)
    self.canny = cv.CreateImage(cv.GetSize(self.image), 8, 1)
    #self.canny = cv.CreateMat(self.image.width, self.image.height, 5)
    self.result = cv.CreateImage((self.canny.width, self.canny.height), 8, 1)

    self.window = cv.NamedWindow("Shellac");
    c = cv.Canny(self.image, self.canny, 500, 500)
    #c = cv.CornerEigenValsAndVecs(self.image, self.canny, 255)
    #c = cv.CornerHarris(self.image, self.canny, 4)
    #cv.SetImageROI(self.result, cv.Rectangle(0, 0, self.canny.width, self.canny.height))
    #cv.Copy(canny, result)
    cv.ShowImage("Shellac", self.canny)
    key = None
    while key not in [113, 1048689]:
      key = cv.WaitKey()
      if key in [115, 1048691]:
        cv.SaveImage(datetime.datetime.now().strftime("out/shellac %Y-%m-%d %H:%M.jpg"), self.canny)
      print key
    print self.image
