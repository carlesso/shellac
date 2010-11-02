#include <stdio.h>

#include <QFile>
#include <QDebug>

#include <opencv/cv.h>
#include <opencv/cvaux.h>
#include <opencv/highgui.h>

#include "vision_core.h"

IplImage *src = 0;
IplImage *canny = 0;
IplImage *out = 0;

int cannyLow = 0;
int cannyHigh = 0;

void cannyLoHandler(int h)
{
    cannyLow = h;
    //qDebug() << "canny low threshold " << QString::number(h);
}

void cannyHiHandler(int h)
{
    cannyHigh = h;
    //qDebug() << "canny high threshold " << QString::number(h);
}

int compute(QString filename)
{
    if (!QFile::exists(filename)) {
        qDebug() << "selected file " << filename << "doesn't exist";
        return -1;
    }

    src = canny = out = 0;

    try {
        src = cvLoadImage( filename.toAscii().data(), 0 );
    }
    catch (cv::Exception exception) {
        fprintf(stderr, "%i, %s:%s:%i:%s",  exception.code,
                                            exception.file.c_str(),
                                            exception.func.c_str(),
                                            exception.line,
                                            exception.err.c_str());

        releaseMem();
        return -1;
    }

    if (!src) {
        fprintf( stderr, "selected file %s doesn't exist\n", filename.toAscii().data() );
        return -1;
    }

    canny = cvCreateImage(cvGetSize(src), 8, 1);

    cannyLow = 25;
    cannyHigh = 150;
    int maxVal = 255;

    while(1) {

        if ( !cvGetWindowHandle("tapi_vision") ) {
            cvNamedWindow("tapi_vision");
            cvCreateTrackbar("low threshold", "tapi_vision", &cannyLow ,maxVal, cannyLoHandler);
            cvCreateTrackbar("high threshold", "tapi_vision", &cannyHigh, maxVal, cannyHiHandler);
        }
        cvCanny( src, canny, cannyLow, cannyHigh );

        out = cvCreateImage( cvSize(2*canny->width, canny->height), 8, 1 );

        cvSetImageROI( out, cvRect( 0, 0, canny->width, canny->height ) );
        cvCopy( src, out );
        cvSetImageROI( out, cvRect( canny->width, 0, canny->width, canny->height ) );
        cvCopy( canny, out );
        cvResetImageROI( out );

        cvShowImage( "tapi_vision", out );

        int key = cvWaitKey(100);

        if(key == 1048603)
            break;

        switch(key) {
          case 'h':
            //...
            break;
          case 'i':
            //...
            break;
        }
    }

    releaseMem();

    return 0;
}

void releaseMem()
{
    if (src)
        cvReleaseImage( &src );

    if (canny)
        cvReleaseImage( &canny );

    if ( out )
        cvReleaseImage( &out );
}
