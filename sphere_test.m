nmics = 30; 
nmeas = 180;
sigs = 2.+rand(nmics,nmeas);
sigs_pseudoDB = log10(sigs);
phi = linspace(0,2*pi,nmeas);
theta = linspace (-pi/2,pi/2,nmics);

[phi,theta] = meshgrid(phi,theta);

[x,y,z] = sph2cart(phi,theta,sigs_pseudoDB);

surf(x,y,z)