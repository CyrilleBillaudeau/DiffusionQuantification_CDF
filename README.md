# General context
The present workflow has been designed to investigate the diffusion properties of bacterial membrane proteins imaged by TIRF using the cumulative distribution function (CDF) approach. The combination of specific labelling and imaging conditions enables single-particle tracking (SPT) to be performed with long tracks and high spatial and temporal accuracy. Frequently, SPT experiments are analysed using the mean-squared displacement (MSD) method. Furthermore, tracking data also provides access to the full probability distribution of squared displacement, which can be analysed to provide a more detailed insight into models of mobility in membranes, such as free or lateral constrained diffusions.

## Analysis of SPT from two-dimensional Brownian motion
Brownian motion is characterised by a probability distribution of displacements $r$ from an origin, $p(r, i&#916;t)$, where $i&#916;t$ designates the time lag, $i$ is the time step index, and $&#916;t$ is the time interval between observations. This distribution has the form of $r$ times a Gaussian centered at the origin, which broadens with time lag with an average mean-square displacement, $r^2 =  4D(i&#916;t)$, with $D$ the diffusion
coefficient. It is often convenient to consider the cumulative radial distribution function, $P(r, i&#916;t)$, which is the probability of finding the diffusing particle within a radius $r$ from the origin at a time lag $i&#916;t$:

$$p(r, i&#916;t)=1-\exp\left[-\frac{r^2}{4D(i&#916;t)}\right]$$

The estimation of the diffusion coefficient, $D$, can be made based on its experimental CDF through the use of analytical expressions. Moreover, it is possible to generalise this to a mixture of dynamic properties, such as two diffusion coefficients, $D_1$ and $D_2$.

$$p(r, i&#916;t)=1-p\exp\left[-\frac{r^2}{4D_1(i&#916;t)}\right] + (1-p)\exp\left[-\frac{r^2}{4D_2(i&#916;t)}\right]$$

where $p$ is the ratio of the population diffusing with $D_1$.

## References
<a id="1">[1]</a> 
Schütz, G. J. *et al.* (1997). 
Single-Molecule Microscopy on Model Membranes Reveals Anomalous Diffusion.
Biophysical Journal, 79, 1073-1080. [link](https://doi.org/10.1016/S0006-3495(97)78139-6)

<a id="2">[2]</a> 
Vrljic, M. *et al.* (2002). 
Translational Diffusion of Individual Class II MHC Membrane Proteins in Cells.
Biophysical Journal, 83, 2681-2693. [link](https://doi.org/10.1016/s0006-3495(02)75277-6)

