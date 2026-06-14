#!/bin/bash
find ~/Изображения/wallpapers -type f | shuf -n 1 | xargs awww img --transition-type random
