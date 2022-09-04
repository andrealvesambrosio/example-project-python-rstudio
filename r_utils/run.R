# Get current directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd('..')

# Install packages
if(!require(reticulate)){install.packages('reticulate')}
if(!require(reticulate)){install.packages('yaml')}

# Get conda config values
conda_config <- yaml::read_yaml('r_utils/config.yaml')

# Create and activate conda env
conda_list <- reticulate::conda_list()
if(conda_config$env_name %in% conda_list$name){
  reticulate::use_condaenv(conda_config$env_name)
}else{
  reticulate::conda_create(envname = conda_config$env_name,
                           pip = TRUE,
                           python_version = conda_config$python_version)
}

# Install packages
requirements <- read.table('requirements.txt', header = FALSE, sep = "", dec = ".")
requirements_packages <- c()
for(lib in requirements[[1]]){
  reticulate::conda_install(conda_config$env_name, lib)
  requirements_packages <- c(requirements_packages, base::strsplit(lib, '==')[[1]][1])
}

# Verify install
packages_installed <- reticulate::py_list_packages(envname = conda_config$env_name)
id_not_installed <- which(!requirements_packages %in% packages_installed$package)
cat('Not installed\n', paste(requirements_packages[id_not_installed], '\n'))

# Activate conda env
reticulate::use_condaenv(conda_config$env_name)
