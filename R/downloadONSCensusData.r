#' Download ONS Census Data
#'
#' Download ONS Census 2021 data in CSV form, a limited R interface for the ONS
#' API.
#'
#' @param dataset_id Character vector of length one, the ONS Dataset ID desired
#' @param census_edition Character vector of length one, the Census year desired
#' @param dataset_version Integer vector of length one, the ONS Dataset Version number
#' @param population Character vector of length one, the ONS Census population type requested (see https://developer.ons.gov.uk/population-types/population-types/)
#' @param dimensions_list List, dimensions and options forming the filter specification (see https://developer.ons.gov.uk/censusfilters/)
#' @param filename Character vector of length one, the name of the CSV file to be saved (do not include the file extension suffix)
#' @param directory_path Character vector of length one, the path of the directory in which the CSV file will be saved
#'
#' @return TRUE on success, FALSE if the request fails, NULL on an unhandled error
downloadONSCensusData <- function(dataset_id,
                                  census_edition = "2021",
                                  dataset_version,
                                  population,
                                  dimensions_list,
                                  filename,
                                  directory_path = "") {

  api_base_url <- "https://api.beta.ons.gov.uk/v1/"
  user_agent_string <- getUserAgent()

  filter_body <- list(
    dataset = list(
      id = dataset_id,
      edition = census_edition,
      version = dataset_version
    ),
    population_type = population,
    dimensions = dimensions_list
  )

  filter_request <- httr::POST(paste0(api_base_url,
                                      "filters"),
                               body = filter_body,
                               encode = "json",
                               httr::user_agent(user_agent_string))

  if(httr::status_code(filter_request) != 201) {
    warning("Request for Census data failed. Please check that the request was valid.")
    return(FALSE)
  }

  filter_response <- filter_request |> httr::content()


  submit_request <- httr::POST(paste0(api_base_url,
                                      "filters/",
                                      filter_response$filter_id,
                                      "/submit"),
                               body = "",
                               encode = "raw",
                               httr::user_agent(user_agent_string))

  if(httr::status_code(submit_request) != 202) {
    warning("Request for Census data failed. Please check that the request was valid.")
    return(FALSE)
  }

  submit_response <- submit_request |> httr::content()
  Sys.sleep(0.005)

  i = 0
  while(i < 10) {
    filter_output_request <- httr::GET(paste0(api_base_url,
                                              "filter-outputs/",
                                              submit_response$filter_output_id),
                                       httr::user_agent(user_agent_string))

    filter_output <- filter_output_request |>
      httr::content()

    if(!is.null(filter_output$downloads$csv$public)) break

    Sys.sleep(0.3)
  }
  if(is.null(filter_output$downloads$csv$public)) {
    warning("Download of requested Census data failed.")
    return(FALSE)
  }


  filepath <- paste0(directory_path,
                     "/",
                     filename,
                     ".csv")

  download_outcome <- utils::download.file(filter_output$downloads$csv$public,
                                           filepath,
                                           headers = c("User-Agent" = user_agent_string))

  if(download_outcome != 0) {
    warning("Download of requested Census data failed.")
    return(FALSE)
  }

  return(filepath)
}
