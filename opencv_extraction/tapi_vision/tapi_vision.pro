#-------------------------------------------------
#
# Project created by QtCreator 2010-10-06T10:59:37
#
#-------------------------------------------------

QT       += core

QT       -= gui

TARGET = tapi_vision

CONFIG   += console \
            debug_and_release

CONFIG   -= app_bundle

TEMPLATE = app

linux-g++: {
    CONFIG(debug, debug|release): {
        message(Creating Makefile.Debug)
        TARGET = tv_dbg
        QMAKE_CXXFLAGS_DEBUG = -g3
    }
    else: {
        message(Creating Makefile.Release)
        TARGET = tv
        QMAKE_CXXFLAGS = -msse3
    }
    MAKEFILE = Makefile
}

SOURCES += main.cpp \
    vision_core.cpp

INCLUDEPATH += /usr/local/include/opencv

LIBS += -L/usr/local/lib \
    -L/usr/lib \
    -lcvaux \
    -lcv \
    -lhighgui

HEADERS += \
    vision_core.h
