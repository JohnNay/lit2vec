model_name <- "docs50"
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
pca <- pca_result$x[,1:3]
save(pca, file = paste0(fp, "pca", model_name, ".Rda"))

# plot
library(ggplot2)
library(ggrepel)
load(paste0(fp, "pca", model_name, ".Rda"))
pcadf <- data.frame(X = pca[,1], Y = pca[,2], Z = pca[,3])
if(wordAndcategory){
  Word <- read.csv(paste0(fp,"word_names.csv"), header = FALSE, stringsAsFactors = FALSE)[,1]
  pcadf$Labels <- c(Branch, Word)
  pcadf$Type <- c(rep("Branch", length(Branch)), rep("Word", length(Word)))
  pcadf$size <- c(rep(3, length(Branch)), rep(1, length(Word)))
  embedding_plot <- ggplot(pcadf[pcadf$Type=="Branch" & ! pcadf$Labels %in% "court" | pcadf$Labels %in% keywords,], aes(x = tspX, y = tspY, color = Type, label= Labels)) +
    geom_text() + theme_bw() + xlab("") + ylab("") + theme(legend.position="none")
} else {
  pcadf$Labels <- labs
  
  p <- ggplot(pcadf, aes(x = X, y = Y, color = Z, label= Labels)) +
    geom_text_repel() + geom_point() +
    theme_classic() + xlab("") + ylab("") + 
    theme(axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          legend.position="none")
  
  pdf(paste0("figs/pca_", model_name, ".pdf"),  width=15, height=15)
  print(p)
  dev.off()
}


x1 <- read.csv(paste0(fp, "docvecs_", model_name, ".csv"), header = FALSE) # ndocs by vec-dim np array
rownames(x1) <-  labs
hc <- stats::hclust(dist(x1))
library(ggplot2)
library(ggdendro)
dendr    <- dendro_data(hc, type="rectangle") # convert for ggplot
clust    <- cutree(hc,k=11)                    # k clusters
clust.df <- data.frame(label=names(clust), cluster=factor(clust))
# dendr[["labels"]] has the labels, merge with clust.df based on label column
dendr[["labels"]] <- merge(dendr[["labels"]],clust.df, by="label")
# plot the dendrogram; note use of color=cluster in geom_text(...)
p <- ggplot() + 
  geom_segment(data=segment(dendr), aes(x=x, y=y, xend=xend, yend=yend)) + 
  geom_text(data=label(dendr), aes(x, y, label=label, hjust=0, color=cluster), 
            size=2.5) + ylab("") +
  coord_flip() + scale_y_reverse(expand=c(0.2, 0)) + 
  theme(axis.line.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_rect(fill="white"),
        panel.grid=element_blank()) +
  scale_fill_brewer(palette = "Dark2") 

pdf(paste0("figs/cluster_", model_name, ".pdf"),  width=10, height=10)
print(p)
dev.off()
