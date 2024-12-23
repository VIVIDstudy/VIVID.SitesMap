
#' Download Source Data
#'
#' Download the source datasets to build the VIVID Site Map
#'
#' @param data_raw_directory Character vector of length one, the path of the data-raw directory
#' @param data_directory Character vector of length one, the path of the data directory
#'
#' @return Logical vector of length one with value TRUE on success.
#' @export
downloadSourceData <- function(data_raw_directory = "data-raw",
                               data_directory = "data") {

  if(!dir.exists(data_raw_directory)) dir.create(data_raw_directory)
  if(!dir.exists(data_directory)) dir.create(data_directory)

  # postcode lookup (2024 Nov)

  postcode_to_bng_lookup_filepath <- downloadExtractZipFile(url = "https://www.arcgis.com/sharing/rest/content/items/b54177d3d7264cd6ad89e74dd9c1391d/data",
                                                            unzip_directory = data_raw_directory,
                                                            unzip_files = "Data/ONSPD_NOV_2024_UK.csv")

  postcode_to_bng_lookup <- data.table::fread(postcode_to_bng_lookup_filepath,
                                              select = c("pcds",
                                                         "oseast1m",
                                                         "osnrth1m"),
                                              col.names = c("postcode",
                                                            "oseast1m",
                                                            "osnrth1m"))

  saveRDS(postcode_to_bng_lookup,
          file = paste0(data_directory,
                        "/postcode_to_bng_lookup.rds"))

  rm(postcode_to_bng_lookup,
     postcode_to_bng_lookup_filepath)


  # Region 2021 (former Government Office Region, England only) boundaries

  england_regions_goem_filepath <- downloadArcGISGeoPackage("6ef5b9a867c04f9ba411559b6f1104fe",
                                                            directory_path = data_raw_directory)

  england_regions_goem <- sf::st_read(england_regions_goem_filepath,
                                      query = "SELECT * FROM RGN_DEC_2021_EN_BUC")

  saveRDS(england_regions_goem,
          file = paste0(data_directory,
                        "/england_regions_goem.rds"))

  rm(england_regions_goem,
     england_regions_goem_filepath)


  # LSOA 2021 boundaries

  england_wales_lsoa_goem_filepath <- downloadArcGISGeoPackage("04c65a08ecff4858bffc16e9ca9356f4",
                                                               directory_path = data_raw_directory)

  england_wales_lsoa_goem <- sf::st_read(england_wales_lsoa_goem_filepath,
                                         query = "SELECT * FROM LSOA_2021_EW_BSC_V4")

  saveRDS(england_wales_lsoa_goem,
          file = paste0(data_directory,
                        "/england_wales_lsoa_goem.rds"))

  rm(england_wales_lsoa_goem,
     england_wales_lsoa_goem_filepath)


  # ONS Census 2021 LSOA population density data

  lsoa_population_density_filepath <- downloadONSCensusData(dataset_id = "TS006",
                                                            dataset_version = 4,
                                                            population = "atc-ts-demmig-ur-pd-oa",
                                                            dimensions_list = list(list(name = "lsoa",
                                                                                        is_area_type = TRUE)),
                                                            filename = "lsoa_pop_density",
                                                            directory_path = data_raw_directory)

  lsoa_population_density <- data.table::fread(lsoa_population_density_filepath,
                                               select = c("Lower layer Super Output Areas Code",
                                                          "Observation"),
                                               col.names = c("LSOA21CD",
                                                             "population_density"))

  saveRDS(lsoa_population_density,
          file = paste0(data_directory,
                        "/lsoa_population_density.rds"))

  rm(lsoa_population_density,
     lsoa_population_density_filepath)

  return(TRUE)
}
