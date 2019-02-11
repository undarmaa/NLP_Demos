# StarSpace_demo.R
# Feb 9, 2019

# install.packages("ruimtehol")


vignette("ground-control-to-ruimtehol", package = "ruimtehol")

help(package = "ruimtehol")


library(ruimtehol)
set.seed(123456789)

## Get some training data
download.file("https://s3.amazonaws.com/fair-data/starspace/wikipedia_train250k.tgz", "wikipedia_train250k.tgz")
x <- readLines("wikipedia_train250k.tgz", encoding = "UTF-8")
# x_orig = x
x=x_orig
x <- x[-c(1:9)]
SIZE=250000
x <- x[sample(x = length(x), size = SIZE)]
FILENAME = paste0("wikipedia_train",round(SIZE/1000,0),"k.txt")
# writeLines(text = x, sep = "\n", con = "wikipedia_train20k.txt")
writeLines(text = x, sep = "\n", con = FILENAME)


## Train
set.seed(123456789)
model <- starspace(file = FILENAME,      #"wikipedia_train20k.txt", 
                   fileFormat = "labelDoc", 
                   dim = 100, #50, 
                   trainMode = 3)
model
# 
# Object of class textspace
# dimension of the embedding: 10
# training arguments:
#   loss: hinge
# margin: 0.05
# similarity: cosine
# epoch: 5
# adagrad: TRUE
# lr: 0.01
# termLr: 1e-09
# norm: 1
# maxNegSamples: 10
# negSearchLimit: 50
# p: 0.5
# shareEmb: TRUE
# ws: 5
# dropoutLHS: 0
# dropoutRHS: 0
# initRandSd: 0.001
# 
embedding <- as.matrix(model)
embedding[c("school", "house"), ]

dictionary <- starspace_dictionary(model)

# install.packages('data.table')
library(data.table)

## Save trained model as a binary file or as TSV so that you can inspect the embeddings e.g. with data.table::fread("wikipedia_embeddings.tsv")
starspace_save_model(model, file = "textspace.ruimtehol",      method = "ruimtehol")
starspace_save_model(model, file = "wikipedia_embeddings.tsv", method = "tsv-data.table")
## Load a pre-trained model or pre-trained embeddings
model <- starspace_load_model("textspace.ruimtehol",      
                              method = "ruimtehol")
model <- starspace_load_model("wikipedia_embeddings.tsv", 
                              method = "tsv-data.table", 
                              trainMode = 3)

## Get the document embedding
starspace_embedding(model, "get the embedding of a full document")


v1 <- starspace_embedding(model, "i like going to movies with my friend")
v2 <- starspace_embedding(model, "i truly enjoy visiting cinema when my buddy comes along")
v3 <- starspace_embedding(model, "he was excited when my sister invited me to a party")
v4 <- starspace_embedding(model, "elephants are covering large distances in search of food")


sum(v1*v2) # 0.66
sum(v1*v3) # 0.47
sum(v1*v4) #-0.09

sum(v2*v3) # 0.25
sum(v2*v4) #-0.003

sum(v3*v4) #-0.04

v2%*%t(v3)
v1%*%t(v4)
