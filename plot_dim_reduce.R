model_name <- "docs"
fp = "data/"
wordAndcategory = FALSE

labs <- read.csv(paste0(fp, "names_", model_name, ".csv"), header = FALSE, stringsAsFactors = FALSE)[,1]

# pca
x1 <- read.csv(paste0(fp, "docvecs_", model_name, ".csv"), header = FALSE) # ndocs by vec-dim np array
stopifnot(nrow(unique(x1)) == nrow(x1))
# convert
X <- as.matrix(x1)
# PCA
pca_result <- prcomp(X, retx=TRUE, scale. = TRUE)
pca <- pca_result$x[,1:2]
save(pca, file = paste0(fp, "pca", model_name, ".Rda"))

# plot
library(ggplot2)
library(ggrepel)
load(paste0(fp, "pca", model_name, ".Rda"))
pcadf <- data.frame(tspX = pca[,1], tspY = pca[,2])
if(wordAndcategory){
  Word <- read.csv(paste0(fp,"word_names.csv"), header = FALSE, stringsAsFactors = FALSE)[,1]
  pcadf$Labels <- c(Branch, Word)
  pcadf$Type <- c(rep("Branch", length(Branch)), rep("Word", length(Word)))
  pcadf$size <- c(rep(3, length(Branch)), rep(1, length(Word)))
  embedding_plot <- ggplot(pcadf[pcadf$Type=="Branch" & ! pcadf$Labels %in% "court" | pcadf$Labels %in% keywords,], aes(x = tspX, y = tspY, color = Type, label= Labels)) +
    geom_text() + theme_bw() + xlab("") + ylab("") + theme(legend.position="none")
} else {
  pcadf$Labels <- labs
  
  p <- ggplot(pcadf, aes(x = tspX, y = tspY, label= Labels)) +
    geom_text_repel() + theme_classic() + xlab("") + ylab("") + 
    theme(axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank())
  
  pdf(paste0("figs/pca_", model_name, ".pdf"),  width=15, height=15)
  print(p)
  dev.off()
}