#' Expectation
#'
#' @param ... What to compute the expectation of
#' @param weights The name of the column containing sample weights. Set to NULL
#' for no weighting.
#' @param keep_df If TRUE, the resulting data frame is returned (which will
#' contain additional columns for conditioned variables).
#' @return A numeric vector containing the computed expectation.
#' @note Assumes a data frame named "dat" is defined in the global environment.
#' This will be modified in future versions.
#' @examples
#' E(Y)
#' E(Y | A == 0)
#' E(Y | A)
#' E(Y | A == 0, C)
#' @export
E <- function(..., weights = "N", keep_df = FALSE) {
  args <- as.list(match.call())
  if("weights" %in% names(args)) args <- args[-which(names(args) == "weights")]
  if("keep_df" %in% names(args)) args <- args[-which(names(args) == "keep_df")]
  if(any(names(args) != "")) stop('"=" used in function arguments. ',
                                  'Replace these with "==".')

  outcome_var <- as.character(as.expression(args[[2]]))
  args <- args[-(1:2)]

  if(grepl("\\|", outcome_var)) {
    vars <- strsplit(outcome_var, "[ ]*\\|[ ]*")[[1]]
    outcome_var <- vars[1]
    arg_extra <- vars[2]
    if(!grepl("==", arg_extra) && grepl("=", arg_extra))
      stop('"=" used in function arguments. ', 'Replace these with "==".')
    args <- c(arg_extra, args)
  }

  df <- dat
  df <- dplyr::rename(df, outcome_var__ = outcome_var)
  # Note: if weights is not in the data frame, then ignore it.
  if(is.null(weights) || !(weights %in% colnames(df))) {
    df <- dplyr::mutate(df, def_weights__ = 1)
  } else {
    df <- dplyr::rename(df, def_weights__ = weights)
  }

  # First subset data onto conditional values:
  args_cond <- args[grepl("=", args)]
  args_group <- args[!grepl("=", args)]

  if(length(args_cond) > 0) {
    for(i in 1:length(args_cond)) {
      cond <- as.character(as.expression(args_cond[[i]]))
      df <- dplyr::filter(df, eval(rlang::parse_expr(cond)))
    }
  }

  df <- df %>%
    dplyr::group_by_(.dots = args_group) %>%
    dplyr::mutate(denom = sum(def_weights__),
                  num = sum(def_weights__ * outcome_var__)) %>%
    dplyr::summarize(E = (num / denom)[1])

  if(!keep_df) {
    df <- as.numeric(df$E)
  }

  return(df)
}

#' Probability
#'
#' @param ... What to compute the probability of
#' @param weights The name of the column containing sample weights. Set to NULL
#' for no weighting.
#' @param keep_df If TRUE, the resulting data frame is returned (which will
#' contain additional columns for conditioned variables).
#' @return A numeric vector containing the computed expectation.
#' @note Assumes a data frame named "dat" is defined in the global environment.
#' This will be modified in future versions.
#' @examples
#' P(Y == 1)
#' P(Y == 0 | A == 0)
#' P(Y | A)
#' P(Y == 1 | A == 0, C)
#' @export
P <- function(..., weights = "N", keep_df = FALSE) {
  args <- as.list(match.call())
  if("weights" %in% names(args)) args <- args[-which(names(args) == "weights")]
  if("keep_df" %in% names(args)) args <- args[-which(names(args) == "keep_df")]
  if(any(names(args) != "")) stop('"=" used in function arguments. ',
                                  'Replace these with "==".')

  outcome <- as.character(as.expression(args[[2]]))
  args <- args[-(1:2)]
  df <- dat

  if(grepl("\\|", outcome)) {
    vars <- strsplit(outcome, "[ ]*\\|[ ]*")[[1]]
    outcome <- vars[1]
    arg_extra <- vars[2]
    if(!grepl("==", arg_extra) && grepl("=", arg_extra))
      stop('"=" used in function arguments. ', 'Replace these with "==".')
    args <- c(arg_extra, args)
  }

  if(grepl("=", outcome)) {
    outcome_var <- gsub("=.*", "", outcome)
    outcome_var <- gsub(" ", "", outcome_var)
  } else {
    outcome_var <- outcome
  }

  # Note: if weights is not in the data frame, then ignore it.
  if(is.null(weights) || !(weights %in% colnames(df))) {
    df <- dplyr::mutate(df, def_weights__ = 1)
  } else {
    df <- dplyr::rename(df, def_weights__ = weights)
  }

  # First subset data onto conditional values:
  args_cond <- args[grepl("=", args)]
  args_group <- args[!grepl("=", args)]
  args_group_w_outcome <- c(outcome_var, args_group)

  if(length(args_cond) > 0) {
    for(i in 1:length(args_cond)) {
      cond <- as.character(as.expression(args_cond[[i]]))
      df <- dplyr::filter(df, eval(rlang::parse_expr(cond)))
    }
  }

  df <- df %>%
    dplyr::group_by_(.dots = args_group) %>%
    dplyr::mutate(denom = sum(def_weights__)) %>%
    dplyr::group_by_(.dots = args_group_w_outcome) %>%
    dplyr::mutate(num = sum(def_weights__)) %>%
    dplyr::summarize(P = (num / denom)[1])

  if(grepl("=", outcome)) {
    df <- dplyr::filter(df, eval(rlang::parse_expr(outcome)))
  }

  if(!keep_df) {
    df <- as.numeric(df$P)
  }

  return(df)
}
