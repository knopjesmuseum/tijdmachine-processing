# Tijdmachine-processing
This [Processing](http://processing.org) sketch uses Java's [RandomAccessFile](https://docs.oracle.com/javase/7/docs/api/java/io/RandomAccessFile.html) to scrub through a very large uncompressed RGB video file (300GB in this case with 1,1 million frames) to be able to lookat interesing phenomena in the video at different time intervals.

# Demo
![Demo movie](demo.gif)

This animated GIF was created using [FFMPEG](https://www.ffmpeg.org/) by converting the TIFF files generated by Processing's `saveFrame()` function using `ffmpeg -i screen-%04d.tif demo.gif`.