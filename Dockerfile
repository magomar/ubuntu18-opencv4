# Docker Image with OpenCV on Ubuntu 18.04
# OpenCV has been installed with a wide range of supporting libraries, excluding CUDA and supporting libraries
# Image size: ~1.2GB
FROM ubuntu:bionic
LABEL MAINTAINER="Mario Gómez <magomar@gmail.com>"
ARG OPENCV_VERSION="4.2.0"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # DEVELOPER TOOLS
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        pkg-config \
        # IMAGE AND VIDEO I/O LIBRARIES
        ffmpeg \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libopenexr-dev \
        libavcodec-dev \
        libavformat-dev \
        libavresample-dev \
        libswscale-dev \
        libv4l-dev \
        libxvidcore-dev \
        libx264-dev \
        # libx265-dev \
        libwebp-dev \
        # GUI BACKEND
        libgtk2.0-dev \
        libgtkglext1-dev \
        # MATH OPTIMIZATIONS
        gfortran \
        libatlas-base-dev \
        # libopenblas-dev \
        # libopenblas-base \
        liblapacke-dev \
        libeigen3-dev \
        # STREAMING
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        # DEVICES
        libdc1394-22-dev \
        udev \
        # THREADING
        libtbb2 \
        libtbb-dev \
        # PYTHON
        python3-dev \
        python3-pip \
        # OTHER
        # libhdf5-dev
        && rm -rf /var/lib/apt/lists/*

#Symlink LAPACK headers
RUN ln -s /usr/include/lapacke.h /usr/include/x86_64-linux-gnu

# Install numpy using pip manager
RUN pip3 install numpy

# INSTALLING OPENCV
WORKDIR /
RUN wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip --no-check-certificate \
    && unzip ${OPENCV_VERSION}.zip \
    && rm ${OPENCV_VERSION}.zip \
    && wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip --no-check-certificate \
    && unzip ${OPENCV_VERSION}.zip \
    && rm ${OPENCV_VERSION}.zip \
    && mkdir /opencv-${OPENCV_VERSION}/build \
    && cd /opencv-${OPENCV_VERSION}/build \
    && cmake -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
        -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DWITH_CUDA=OFF \
        -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON \
        -DWITH_IPP=ON \
        -DWITH_TBB=ON \
        -DWITH_EIGEN=ON \
        -DWITH_V4L=ON \
        -DBUILD_OPENCV_JAVA=OFF \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_OPENCV_PYTHON3=ON \
        -DBUILD_OPENCV_PYTHON2=OFF \
        -DPYTHON_EXECUTABLE=$(which python3.6) \
        -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
        -DINSTALL_C_EXAMPLES=OFF \
        -DINSTALL_PYTHON_EXAMPLES=OFF \
        .. \
    && make --jobs=$(nproc --all) \
    && make install \
    && ldconfig \
    && rm -rf /opencv-${OPENCV_VERSION} \
    && rm -rf /opencv_contrib-${OPENCV_VERSION}

# SymLink OpenCV4 binaries for Python3 usage
RUN ln -s \
  /usr/lib/python3.6/dist-packages/cv2/python-3.6/cv2.cpython-36m-x86_64-linux-gnu.so \
  /usr/lib/python3/dist-packages/cv2.so
