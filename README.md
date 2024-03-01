![Banner Image](figs/banner.png)
# Low-Cost IoT Technology for Runoff Water Quality Comparison with Traditional Methods
Repository Created by A.J. Brown, 27 Feb 2024
  
**Principal Investigators:** Ansley "AJ" Brown, Erik Wardle, Emmanuel Deleon, and Christina Welch  
**Affiliation:** Colorado State University, Agricultural Water Quality Program, Soil and Crop Sciences Department

> !NOTE
> This repository is a work in progress and is not yet complete. Please check back for updates.

## Abstract

In Colorado and across the United States, agriculture is identified as a source of nutrient pollution in state and federal waters, with nutrients such as nitrogen and phosphorus running off farmlands into surface waterways, causing quality issues. Despite the lack of regulation for agricultural nonpoint sources in Colorado, initiatives encourage adopting Best Management Practices (BMPs) to protect surface water quality. 

The Colorado State University Agricultural Water Quality Program (AWQP) has developed a low-cost, automated water sampler (LCS) with Internet of Things (IoT) technology for scalable, near-real-time water quality research. This development follows from an awarded NRCS Conservation Innovation Grant and shows promise in comparison to commercial-grade equipment and manual collection methods. The project aims to compare water quality and quantity measurements from commercial-grade equipment, the LCS IoT apparatus, and manual data collection methods at a study site in Fort Collins, CO with varying runoff water qualitites due to diverser tillage practices.

A baysian approach is used in this analysis to compare water quality measurements from the four methods due to robust quantification of uncertainty and measurement error from this approach. The results of this study will be used to inform future research and provide a methodology for evaluating other sample collection methods and technologies henceforth.

## Objectives

- Compare and contrast water quality and quantity measurements collected from 4 methods:
    1. **Commercial-grade equipment:** collecting first flush and subsequent hourly samples, composited for each runoff event
    2. **LCS:** collecting first flush and subsequent hourly samples, composited for each runoff event
    3. **Manual collection 1:** water samples collected in a plastic bottle by hand at first flush, then at each susbsequent hour, composited for each runoff event.
    4. **Manual collection 2:** water samples collected in a plastic bottle by hand at first flush, then at the first hour after first flush, then at the last hour of the runoff event, composited.

## Table of Contents


## Repository Structure
* `0_docs/` - contains project documentation, including code output reports
* `1_data/` - contains raw data files, including real and simulated data for testing
* `2_code/` - contains source code for data simulation, analysis testing, and real analysis
* `figs/` - contains figures needed for the repository readme file
* `LICENSE.md` - this code is licensed under the GNU General Public License v2.0

## Experimental Design and Data Collection
### Study Site

The study site is located at the CSU Agricultural Research, Development and Education Center (ARDEC) (40˚40′40″N, 104˚59′51″W) near Fort Collins, CO. Located at 1570 m above sea level, the area has an average annual precipitation of 407 mm with an average monthly maximum and minimum temperatures of 17.6 ˚C and 2.7 ˚C, occurring in July and January, respectively. Soils at the site are dominated by Garrett sandy-loams (fine-loamy, mixed, mesic type of Pachic Argiustoll; Soil Survey, 2016) with an average organic matter content of 1.8%, a pH of 7.8, and a textural profile of 52 % sand, 18 % silt, and 30 % clay. This soil type is representative of a high percentage of soils in Northern Colorado irrigated agriculture. 

In 2011, the site was established to compare two conservation tillage treatments, minimum till (MT) and strip till (ST), with a conventional tillage control treatment (CT) that is representative of typical practices in furrow irrigated fields of northern Colorado. The MT and ST treatments were selected in collaboration with a group of advising farmers interested in the feasibility of conservation tillage for furrow-irrigated systems. The field contains relatively large field plots (320 m long × 27 m wide) to realistically represent water movement in furrows and associated challenges with commercial production fields in the region. For the 2023 growing season, the study field was planted in silage corn in late April and harvested in mid-September. Winter wheat was planted immediately afterward and will be harvested in July 2024.

### Edge-of-Field Runoff Monitoring Setup

The edge-of-field (EoF) runoff monitoring setup consists of a commercial-grade automated water sampler, an LCS, a a furrow flume. The placement of each EoF site is located at the bottom of the field, and can be seen in Figure 1:

![Figure 2: Plot Map](figs/plots.png)
*Figure 2.* Plot map of the conservation tillage study site where water samples will be collected, located at CSU ARDEC, Fort Collins, CO.

A more detailed depiction of the equipment and it's orientation at each EoF site can be found in Figure 2:

![Figure 2: Edge-of-Field Runoff Monitoring Setup](figs/eof.png)
*Figure 2.* Edge-of-Field Runoff Monitoring Setup. The LCS and commercial sampler are located at the bottom of the field, near an installed furrow flume. Grab samples are collected by hand from water flowing through the furrow flume.  The LCS and commercial sampler use the same flume for flow measurement.


### Water Quality Analysis
Water samples collected from all sampling methods will be analyzed for the following as per NRCS Conservation Evaluation and Monitoring Activity (CEMA) 201 (NRCS, 2012): Ammonium Nitrogen (EPA 350.1), Nitrate-Nitrite (EPA353.2), Total Phosphorus (EPA365.2), Total Kjeldahl Nitrogen (A4500-NH3), Orthophosphate as P (EPA300), and Total Suspended Solids (EPA160.2). Additionally, the AWQP will add the following tests to encompass salinity, pH, and biological measurements: Total Dissolved Solids (EPA 160.1), specific conductance (EPA 120.1), pH (EPA 150.1), and total coliforms (EPA 1604).

Total suspended solids, specific conductance, and pH will be measured at the CSU AWQP laboratory, whereas the remaining analyte analyses will be outsourced to ALS Environmental within proper hold times.


## Data Analysis

This analysis will be performed using R via Rstudio in conjunction with the `rethinking`, `cmdstanr`, and `dplyr` packages.

The procedure will be as follows:
1. Simulate a testing dataset to ensure the analysis code is functioning properly
2. Create a causal model to compare the four sampling methods using a directed acyclic graph (DAG)
3. Use the DAG to create a statistical model for the analysis
4. Create the statistical model in R using the `rethinking` package
5. Test the model using the simulated data and verify model functionality
6. Analyze the real data using the verified model
7. Interpret the results

### Simulate data
Simulated data come from an r script specifically built to represent a similar scenario with similar data, but with known influences of each variable on the result (e.g., make each sampler type have it's own bias on analyte concentration).  This will allow us to test the model and ensure it is functioning properly before using real data.

The script to generate the simulated can be found in `2_code/data_sim.R`, and the results can be found in `0_data/sim_data.csv`.

### Create a causal model
Produced by [dagitty.net](https://www.dagitty.net/dags.html#), the causal model is a directed acyclic graph (DAG) that represents the relationships between the variables in the study.  This model will be used to create the statistical model in R.

![Figure 3: Causal Model](figs/dag.png)

Where sampler method (S) and tillage treatment (T) influence the unobserved true concentration (C), which in turn influences the observed concentration (C*). The observed concentration is also influenced by measurement error (*e*).

Here was the code used to generate the DAG:

```{r}
dag {
"Measurement Error" [pos="0.158,-1.083"]
"Obs. Conc." [outcome,pos="-0.414,-0.561"]
"Sampler Method" [exposure,pos="-1.296,-0.978"]
"Tillage Treatment" [exposure,pos="-1.270,-0.285"]
"True Conc." [latent,pos="-0.918,-0.566"]
"Measurement Error" -> "Obs. Conc."
"Sampler Method" -> "True Conc."
"Tillage Treatment" -> "True Conc."
"True Conc." -> "Obs. Conc."
}
```

### Create the statistical model
The statistical model is created using the DAG and the following assumptions:
$$ C_i \sim Normal(\mu_i, \sigma) $$
$$ \mu_i = \alpha + \beta_{S}S_i + \beta_{T_i}T_i $$
$$ C* = C_i + e_{C,i} $$
$$ e_{C,i} \sim Normal(0, \sigma_{C}) $$

Because the a feature of normal distributions is that the sum of two normal distributions is also normal, we can simplify the model to:
$$ C_i \sim Normal(\mu_i, \sigma) $$
$$ \mu_i = \alpha + \beta_{S}S_i + \beta_{T_i}T_i $$
$$ C* \sim Normal(D_i, \sigma_{C}) $$

**A comment on clusters v. features:**

*Clusters* are kinds of groups within the data (e.g., irrigation event count or analyte type)

*Features* are aspects of the model (parameters) that vary by cluster (e.g., the effect of sampler method or tillage treatment on the observed concentration)

### Create the statistical model in R
The source code for the statistical model can be found in `2_code/analysis.Rmd` and `2_code/analysis_test.Rmd`.

### Test the model using the simulated data
Using the simulated data, the model was tested to ensure that the model functions as intented.  The results can be found in `0_docs/analysis_test.html`.

### Analyze the real data
The real data was analyzed using the verified model.  The results can be found in `0_docs/analysis.html`.

### Interpret the results
TBD

## Conlusion
TBD