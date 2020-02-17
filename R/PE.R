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
  df <- rename(df, outcome_var__ = outcome_var)
  if(is.null(weights)) {
    df <- mutate(df, def_weights__ = 1)
  } else {
    df <- rename(df, def_weights__ = weights)
  }

  # First subset data onto conditional values:
  args_cond <- args[grepl("=", args)]
  args_group <- args[!grepl("=", args)]

  if(length(args_cond) > 0) {
    for(i in 1:length(args_cond)) {
      cond <- as.character(as.expression(args_cond[[i]]))
      df <- filter(df, eval(rlang::parse_expr(cond)))
    }
  }

  df <- df %>%
    group_by_(.dots = args_group) %>%
    mutate(denom = sum(def_weights__),
           num = sum(def_weights__ * outcome_var__)) %>%
    summarize(E = (num / denom)[1])

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

  if(is.null(weights)) {
    df <- mutate(df, def_weights__ = 1)
  } else {
    df <- rename(df, def_weights__ = weights)
  }

  # First subset data onto conditional values:
  args_cond <- args[grepl("=", args)]
  args_group <- args[!grepl("=", args)]
  args_group_w_outcome <- c(outcome_var, args_group)

  if(length(args_cond) > 0) {
    for(i in 1:length(args_cond)) {
      cond <- as.character(as.expression(args_cond[[i]]))
      df <- filter(df, eval(rlang::parse_expr(cond)))
    }
  }

  df <- df %>%
    group_by_(.dots = args_group) %>%
    mutate(denom = sum(def_weights__)) %>%
    group_by_(.dots = args_group_w_outcome) %>%
    mutate(num = sum(def_weights__)) %>%
    summarize(P = (num / denom)[1])

  if(grepl("=", outcome)) {
    df <- filter(df, eval(rlang::parse_expr(outcome)))
  }

  if(!keep_df) {
    df <- as.numeric(df$P)
  }

  return(df)
}
