# VIVID.SitesMap

A repo containing the code to download the required data and then generate an
image showing the:

-   population density of England and Wales (based on Census 2021 Lower layer
    Super Output Areas [LSOAs] and Census 2021 population data)
-   boundaries of the regions of England (formerly known as Government Office
    Regions [GORs])
-   sites (point-based) supplied by the user, based on user-supplied postcodes
    mapped to the British National Grid (CRS: 27700) using the Office for
    National Statistics Postcode Directory (ONSPD), November 2024 release.

This repo contain a number of helper function for downloading 
[Office for National Statistics](https://www.ons.gov.uk/) (ONS) datasets using 
the [ONS API](https://developer.ons.gov.uk/) and another API behind the
[ONS Open Geography portal](https://geoportal.statistics.gov.uk/).
