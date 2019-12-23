# Optics 212 Final Project GUI Curve Fitting Tool

Team: Heriniaina Rajaoberison, Lucas Vosatka, Yuning Xia
12/07/2019

This interface allows the user to select noisy data and fit them to a desired form of function.
The user will first select and import an excel sheet that contains data.
It should have
1. the independent variable values in the first column 2. the dependent variable values in the second column.
Then the user can select the type of function they want to fit. The following forms may be selected from a drop down menu:
to
For
After
1. Linear function
2. Polynomial function
3. Single exponential function 4. Double exponential function 5. Gaussian distribution
6. Custom, nonlinear function
NOTE: for the custom, nonlinear fitting, the user will be asked
input the function manually. It does not need to be in function handle form, but it should be inputted in proper matlab syntax.
example, [y = x^3] should be inputted properly as [y = x.^3].
a selection of fitting type, the form of the function and the

constants involved will be shown. These constants will be listed in the order as they will be outputted after the fitting process.
For the custom, nonlinear fitting, the user will be asked to input the number of constants, their variables, and their starting values for the optimization process.
Press the "Optimize!" button to see the results. The interface will output:
1. the noisy data and the fitted curve on a single set of axes 2. the fitted constants
3. the R-squared value for the fit
Help file written by: Yuning Xia
