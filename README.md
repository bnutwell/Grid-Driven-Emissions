# Grid-Driven-Emissions
 Rshiny dashboard for EV emissions based on local power grid

This tool helps consumers visualize the direct and indirect emissions of various 2022 model vehicles.
For Internal Combustion Engine (ICE) vehicles, emissions are calculated based on fuel economy and US emissions standards
For Electric Vehicles (EVs), emissions are calculated based on the required kWh of driving energy, and the mix of power sources in the local power grid.
Example: In West Virginia, the power grid is supplied by 95% coal power, which produces high CO2 emissions.  In eastern Virginia, power is 90% renewable (nuclear/wind/solar).

To use:
- Launch the "server.R" file and ensure you have the correct libraries installed
- Dashboard will be launched in a separate window, or can be opened in a browser window
- Change your driving parameters and ZIP code on the worksheet in the left pane, and compare fuel costs and CO2 emissions of the EV and ICE vehicles in the right tables
- Experiment with other ZIP codes:  43017 in Ohio is high emissions, 23454 in Virginia is very low emissions per kWH
