#include <QtCore/QCoreApplication>
#include <vision_core.h>

int main(int argc, char *argv[])
{
    //QCoreApplication a(argc, argv);

    // compute test
    compute( QString(argv[1]) );

    //return a.exec();
}
