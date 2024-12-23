
#' Prepare Geometry Data
#'
#' Prepare geometry data for plot
#'
#' @param sites_csv Character vector of length one, the full path to CSV file of the sites to be plotted (and their postcodes)
#' @param data_directory Character vector of length one, the path to the data directory
#'
#' @return List of geometry data for plot
prepareGeoData <- function(sites_csv,
                           data_directory) {

  sites <- data.table::fread(sites_csv,
                             select = c("site_name",
                                        "postcode",
                                        "notes"))

  sites[, notes := factor(notes,
                          levels = c("National site",
                                     "New contributor"))]

  postcode_to_bng_lookup <- readRDS(file = paste0(data_directory,
                                                  "/postcode_to_bng_lookup.rds"))

  sites <- merge(sites,
                 postcode_to_bng_lookup,
                 by = "postcode",
                 all.x = TRUE)

  sites_geom <- sf::st_as_sf(sites,
                             coords = c("oseast1m",
                                        "osnrth1m"),
                             crs = 27700)

  lsoa_population_density <- readRDS(file = paste0(data_directory,
                                                   "/lsoa_population_density.rds"))

  density_max <- stats::quantile(lsoa_population_density$population_density, probs = 0.9, type = 8)
  lsoa_population_density[population_density > density_max, population_density := density_max]

  england_wales_lsoa_goem <- readRDS(file = paste0(data_directory,
                                                   "/england_wales_lsoa_goem.rds"))

  england_wales_population_density_geom <- merge(england_wales_lsoa_goem,
                                                lsoa_population_density,
                                                by = "LSOA21CD")

  england_regions_goem <- readRDS(file = paste0(data_directory,
                                                "/england_regions_goem.rds"))

  return(list(sites_geom = sites_geom,
              england_wales_population_density_geom = england_wales_population_density_geom,
              england_regions_goem = england_regions_goem))

}
