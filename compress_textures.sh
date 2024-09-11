#!/bin/bash

cd ./ts_vehicles_api/textures
pngquant --skip-if-larger --quality=100 --strip *.png --ext .png --force

cd ../../ts_vehicles_common/textures
pngquant --skip-if-larger --quality=100 --strip *.png --ext .png --force

cd ../../ts_vehicles_cars/textures
pngquant --skip-if-larger --quality=100 --strip *.png --ext .png --force

cd ../../ts_vehicles_helicopters/textures
pngquant --skip-if-larger --quality=100 --strip *.png --ext .png --force
