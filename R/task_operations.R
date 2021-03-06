addTask <- function(jobId, taskId = "default", content = "parsed", ...){
  batchCredentials <- getBatchCredentials()

  args <- list(...)
  environmentSettings <- args$environmentSettings
  resourceFiles <- args$resourceFiles
  commandLine <- args$commandLine
  dependsOn <- args$dependsOn
  outputFiles <- args$outputFiles
  exitConditions <- args$exitConditions

  if (is.null(commandLine)) {
    stop("Task requires a command line.")
  }

  body <- list(id = taskId,
              commandLine = commandLine,
              userIdentity = list(
                autoUser = list(
                  scope = "pool",
                  elevationLevel = "admin"
                )
              ),
              resourceFiles = resourceFiles,
              environmentSettings = environmentSettings,
              dependsOn = dependsOn,
              outputFiles = outputFiles,
              constraints = list(
                maxTaskRetryCount = 3
              ),
              exitConditions = exitConditions)

  body <- Filter(length, body)

  size <- nchar(rjson::toJSON(body, method = "C"))

  headers <- c()
  headers['Content-Length'] <- size
  headers['Content-Type'] <- "application/json;odata=minimalmetadata"

  request <- AzureRequest$new(
    method = "POST",
    path = paste0("/jobs/", jobId, "/tasks"),
    query = list("api-version" = apiVersion),
    headers = headers,
    body = body
  )

  callBatchService(request, batchCredentials, content)
}

listTask <- function(jobId, content = "parsed", ...){
  batchCredentials <- getBatchCredentials()

  args <- list(...)
  skipToken <- args$skipToken

  if (!is.null(skipToken)) {
    query <- list("api-version" = apiVersion,
                  "$skiptoken" = skipToken)
  }
  else {
    query <- list("api-version" = apiVersion)
  }

  request <- AzureRequest$new(
    method = "GET",
    path = paste0("/jobs/", jobId, "/tasks"),
    query = query
  )

  callBatchService(request, batchCredentials, content)
}
