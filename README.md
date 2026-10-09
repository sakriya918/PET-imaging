# PET Simulation and Image Reconstruction

This project simulates a Positron Emission Tomography (PET) setup and its underlying physics in **GEANT4**. Fluorine-18 is decayed to generate positrons, which annihilate upon colliding with electrons, producing the back-to-back gamma photons that PET detectors register as coincidence events. The simulation captures the full chain from radioactive decay through annihilation to detection.

Image reconstruction is carried out in **MATLAB**. Bresenham's line algorithm is used to trace the lines of response between detector pairs, and these are accumulated into an equivalent sinogram. The Radon transform (inverse, via filtered back-projection) is then applied to the sinogram to reconstruct the original activity distribution as an image.

#PET #GEANT4 #MATLAB #MedicalImaging #ImageReconstruction #RadonTransform #Sinogram #NuclearMedicine
