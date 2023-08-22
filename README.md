# ColorSensor
The objective of this group project was to construct a device capable of detecting colors using a single
photodiode and a RGB LED.

The market for color detecting sensors of this type has seen a steady growth in the recent years, since they are used in various industries including automotive, manufacturing, textiles, chemical, food and beverage, pharmaceutical. The purposes of this device are varied: in consumer electronics they are used for backlight control and display calibration, in manufacturing for detecting components and matching their colors, and they are even used for fluid and gas analysis and in the pharmaceutical field. The characteristic most sought after by producers is the ability for the sensor to be able to differentiate accurately and consistently a lot of shades of colors
both in the market for private citizens and in the one for businesses. This is often achieved by using more photodiodes with coloured filters in an array configuration and by working digitally, reaching accuracies of ±0.5% F.S. Since our sensor only uses one photodiode and works analogically it reaches a lower accuracy while allowing for a wider range of applications.
The device itself works thanks to the photodiode, a sensor capable of transforming light irradiance into current, and therefore sensible to the light intensity. Based on the properties of color reflection, we knew that the resulting output current of the PD represented how optimal the light reflection had been, and an optimal color reflection means that either the surface is white, therefore reflecting all wavelengths, or the same color as the transmitted one.

### Working principle
![image](https://github.com/masal-98/ColorSensor/blob/c47c70f36c8f53dac4e1d86b127bb8c4cab6abf7/Color%20sensor%20images/principle.PNG)

With these properties in mind, we created a color sensor which would work following this procedure: by sequentially illuminating the object with the three colors of the LED, and measuring the current output given by the photodiode, for each of those LED colors, we could assign three values of color intensity to the object in an RGB format, and put them together to obtain an estimation of the unknown color.
In order to translate the output of the photodiode into RGB values, we needed to properly calibrate the device, meaning we had to retrieve the color range of converted currents using only a simple black and white calibration. The white calibration, giving the highest photodiode response, consisted in sequentially radiating a white piece of paper with the LEDs and measuring the photodiode output for each of the colors, namely rw, gw and bw. The black calibration consisted in measuring the output signal without turning on the LED, in order to measure the dark currents, getting rb, gb, bb.

Therefore, the color detection worked thanks to the following equations. While presenting a
colored object to the sensor, the three measured intensities - rc, gc, bc - are then converted into
a value between 0 and 255 with respect to the ranges of measurements for each color component,
obtained with the black and white calibration.

![image](https://github.com/masal-98/ColorSensor/blob/9b90adec1e1d7153bc89889e04da694eab52ccb4/Color%20sensor%20images/coefficients.PNG)

After acquiring a professional color palette with exact RGB values, we decided to do a further calibration in order to compare it with the initial one. This consisted not only in the use of the black and white range obtained before, but with the addition of selecting 70 different colors in the color palette, measuring the R, G, B components by following the same process described above and then plotting the real values against the measured ones
on Excel.

By applying a 3rd order polynomial regression analysis to those graphs, we obtained a set of coefficients allowing us to convert the R, G, B calculated values into ones closer to the reality and therefore having the best accuracy possible. For example, the red component of a color is now first computed thanks to the equation, and then by applying the correction coefficients:
Rcorr = 0.0000132053R^3 − 0.0081525719R^2 + 2.2194214917R 
Those resulting coefficients are saved in the memory of the device along with the white and black ranges (since we verified they are constant over time), in order to remove the need of performing a calibration on the user’s end, thus making our device factory calibrated.

# GUI
![image](https://github.com/masal-98/ColorSensor/blob/c47c70f36c8f53dac4e1d86b127bb8c4cab6abf7/Color%20sensor%20images/color%20GUI.PNG)



# Hardware schema
![image](https://github.com/masal-98/ColorSensor/blob/3f54e840d07387da64b9230f426652766ade9c57/Color%20sensor%20images/schema.PNG)

For the complete breakdown of this project, the report is available on the repository.
