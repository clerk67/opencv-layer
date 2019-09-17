FROM lambci/lambda:build-python3.7

ENV OPENCV_VERSION 3.4.7

RUN curl -fsSLO https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz \
  && tar -zxf $OPENCV_VERSION.tar.gz \
  && mv opencv-$OPENCV_VERSION opencv

RUN curl -fsSLO https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.tar.gz \
  && tar -zxf $OPENCV_VERSION.tar.gz \
  && mv opencv_contrib-$OPENCV_VERSION opencv_contrib

RUN yum install -y cmake3

RUN pip install --upgrade pip && pip install numpy

RUN mkdir opencv/build \
  && cd opencv/build \
  && cmake3 \
    -DBUILD_SHARED_LIBS=NO \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=../../python \
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DPYTHON3_EXECUTABLE=/var/lang/bin/python .. \
  && make install

RUN find python/lib -name *.so | xargs -n 1 strip -s

RUN zip -ry9 cv2.zip python/lib

CMD cp cv2.zip /share
