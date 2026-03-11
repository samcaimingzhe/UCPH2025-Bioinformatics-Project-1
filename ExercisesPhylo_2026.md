# Phylogenomics

**David A. Duchene**

Marsupials are a group of mammals that are unique to Australasia and the Americas. Several major groups of marsupials first appeared between 50 and 70 million years ago, during events of fast diversification. Given these are ancient and fast events, resolving the relationships among early marsupials is difficult, and remains a matter of interest in mammalian biology.

Today's exercises focus on the most fundamental concepts in phylogenomics, with the aim of resolving longstanding questions of the evolution of Australasian marsupials.

Let's make sense of our current understanding of marsupial relationships by coding them in newick format.

### Exercise 1:

Open R, load the ape package.

```coffee
library(ape)
library(strap)
```

Create an object containing a newick tree.

```coffee
myTree <- read.tree(text = "WRITE NEWICK HERE")
```

To write this tree, follow the verbal description of marsupial relationships in newick format:

The Wallabies are sisters to the Kangaroos, and this broader grouping is sister to the Possums. Sister to all these is the grouping that contains the Koalas and the Wombats. Yet another, separate group of marsupials contains the carnivorous Numbats, whose sister is a group containing the Tasmanian Devil and the now-extinct Tasmanian Tiger. It is hypothesised that that the sister to these carnivorous marsupials is a group containing the Marsupial Mole, whose closer sister is a group containing the Bandicoots and the Bilby. Sister to all of the marsupials mentioned so far is the enigmatic American Monito del Monte, and sister yet to all of these are the American Opossums. Finally, the Platypus and the Echidna form a group that is sister to all other mammals.

Make sure you add a semicolon (;) at the end of your tree. Now attempt to rearrange the names around so that they are in order of the least diverse to the most, while maintaining the relationships intact.

Compare your tree with the student sitting next to you. Discuss whether the newick trees are different. Then evaluate whether the relationships in your trees are the same, even if the exact written text string is different.

If you get too many errors, then use:

```coffee
myTree <- read.tree(text = "((Elephant,Armadillo),(((Squirrel,Rabbit),(Monkey,Treeshrew)),(Shrew,(Whale,(Bat,(Cat,Rhinoceros))))));")
```

Now plot your tree into a PDF using two different representations:

```coffee
pdf("myTree.pdf", height = 7, width = 14)
par(mfrow = c(1, 2))
plot(myTree, type = "phylogram")
plot(myTree, type = "unrooted")
dev.off()
```

Q1. Do the two trees in the file contain the same information?

Q2. Can you draw any information from the branch lengths in these trees?

Q3. What information about the timing of each of these divergence events is available in the first tree?

Q4. Which of the two trees might be the most appropriate in cases where you have little prior information about the data set?


### Exercise 2:

Load two data alignments, and then open the basic information about them and visualize a small portion:

```coffee
# Read data
unaligned_mars <- read.FASTA("marsupials_unaligned.fasta")
aligned_mars <- as.matrix(read.FASTA("marsupials_aligned.fasta"))

###########################
# Summary of unaligned data
###########################
unaligned_mars


###########################
# Summary of aligned data
###########################
aligned_mars


#########################
# Start of unaligned data
#########################
noquote(do.call(rbind, lapply(as.character(unaligned_mars), `[`, 1:10)))


#########################
# Start of aligned data
#########################
noquote(as.character(aligned_mars)[1:11, 1:10])
```

Q5. What are the primary differences between these two alignments, and why is only one of them suitable for phylogenetic inference?

The following code will remove any alignment sites (columns) with missing data (aka gaps or indels). It then builds basic trees from the complete and filtered alignments using two methods (ordinary least squares, ols, and balanced minimum evolution, bme):

```coffee
# Filter out sites with missing data 
filtered_mars <- aligned_mars[, !colSums(as.character(aligned_mars) == "-") > 0]


# Make matrices of pairwise distances between taxa
dists_full <- dist.dna(aligned_mars, model = "K80", pairwise.deletion = T)
dists_filt <- dist.dna(filtered_mars, model = "K80")

# Make trees for the two data sets, under two methods each
basicTrees <- list()
basicTrees$full_ols <- fastme.ols(dists_full)
basicTrees$full_bme <- fastme.bal(dists_full)
basicTrees$filt_ols <- fastme.ols(dists_filt)
basicTrees$filt_bme <- fastme.bal(dists_filt)
```

Q6. Before looking at any of the trees, what do you think are the benefits and drawbacks of removing sites with missing data?

Try plotting a few of these trees with the approaches that you used in Exercise 1.

Next, we will look at the total lengths of these trees.

```coffee
lapply(basicTrees, function(x) sum(x$edge.length))
```

Q7. What do these tree lengths measure?

Q8. Why is there a difference between the filtered and unfiltered data sets?

Do not worry at this stage about the differences between the two methods, but if you have time discuss with your partner what the difference is and what it means for your interpretation of the data.


### Exercise 3:

From within R, let's run IQ-TREE 3 under two different substitution models, adding statistical supports for the branches (upcoming lecture):

```coffee
# Run maximum-likelihood with a very simple model
system("iqtree3 -s marsupials_aligned.fasta -m JC -bb 1000 -pre mars_jc")
# Run maximum-likelihood with a more complex model
system("iqtree3 -s marsupials_aligned.fasta -m GTR+R6 -bb 1000 -pre mars_gtr")
```

Now let's visualise the trees from the three different methods so far.

```coffee
# Read maximum likelihood trees
mars_jc <- read.tree("mars_jc.treefile")
mars_gtr <- read.tree("mars_gtr.treefile")

# Plot all four inferred trees into a PDF
pdf("marsupial_trees.pdf", height = 10, width = 10)
par(mfrow = c(2, 2))
plot(basicTrees$full_ols, type = "unrooted", main = "Ordinary Least Squares")
plot(basicTrees$full_bme, type = "unrooted", main = "Balanced Min Evolution")
plot(mars_jc, type = "unrooted", main = "Max Likelihood (JC)")
plot(mars_gtr, type = "unrooted", main = "Max Likelihood (GTR)")
dev.off()
```

Q9. Do you think that these methods lead to substantially different results? Lay out a few reasons for your answer.


### Exercise 4:

Using the runs from the previous exercise, let's open the .iqtree files from each run (you can then exit by pressing 'q') and examine some of the details of the analyses.

```coffee
# Output summary for the run with the simple model
system("less mars_jc.iqtree")

# Output summary for the run with the more complex model
system("less mars_gtr.iqtree")
```

Q10. Which of the two models has more parameters (more complexity) and which model has the best BIC score (i.e. the lowest), and what does this tell you about the two models?

Q11. Does one model infer the total tree length to be much greater than the other? Discuss the possible reason for this with the student beside you.

Q12. From the GTR run and 'Rate Parameter R', which pairs of nucleotides has the most common type of substitution, and does this tell you anything about the biochemistry of the molecules analysed?

Q13. From the same run and the 'Model of rate heterogeneity', are there any portions of the data that evolve much faster than the rest? Note that, for example, a relative rate of 2 a portion of the data is evolving twice as fast as the mean.

Q14. From the time stamps at the bottom of this file, did one model take much longer than the other, and what could this mean if you have a very large data set?


Now let's examine the branch supports from one of these runs, using the tree that you loaded previously onto R.

```coffee
pdf("mars_branch_supports.pdf")
plot(mars_gtr, type = "unrooted", use.edge.length = F)
nodelabels(mars_gtr$node.label, frame = "circle", bg = "white")
dev.off()
```

Q15. What does this tell you about our overall confidence in marsupial relationships from these data, and which are likely the most difficult relationships to resolve?


### Exercise 5:

A previous set of analyses has led to the gene trees for several genomic regions. Read and briefly explore these data in R.

```coffee
mars_trs <- read.tree("marsupials.tree")

# Plot 9 randomly chosen trees from the set
pdf("mars_example_gene_trees.pdf", height = 15, width = 15)
par(mfrow = c(3, 3), mar = c(0.5, 0.5, 0.5, 0.5))
for(i in sample(1:length(mars_trs), 9)) plot(mars_trs[[i]], type = "unrooted", cex = 1.5)
dev.off()
```

Examine the trees in the PDF and determine whether any of them have surprising relationships at deep branches. Speculate on the possible causes of the discordance (hint: what could be the influence/relevance of the branch lengths?).

Let's use these trees and a fast consensus method of tree inference, and compare the tree with that from maximum likelihood.

```coffee
mars_cons <- consensus(mars_trs, p = 0.5)

pdf("mars_main_trees.pdf", height = 7, width = 14)
par(mfrow = c(1, 2))
plot(mars_gtr, type = "unrooted", main = "Max Likelihood (GTR)")
plot(mars_cons, type = "unrooted", main = "Majority-Rule Consensus")
dev.off()
```

Q16. How would you qualify the signal in the gene trees regarding the early branching events in the marsupial tree, and what do you think were the biological processes that led to this signal?


### Exercise 6:

Molecular dating is a difficult and advanced analysis. However, we can sometimes rely on fast methods for very large data sets or exploratory analysis. In the following, we root our tree of the marsupials and provide it to a fast dating method. We apply two calibrations: one for the root (65-90Mya) and one for the split between Koalas and Wombats (2.5-5.5Mya).

```coffee
# Root IQ-TREE inference
mars_tr <- root(mars_gtr, "Opossum", resolve.root = T)

# Perform dating analysis
ctrl <- chronos.control(dual.iter.max = 1000)
cal <- data.frame(node = c(20, 12), age.min = c(2.5, 6.5), age.max = c(5.5, 9))
mars_dated <- chronos(mars_tr, calibration = cal, control = ctrl)
mars_dated$edge.length <- mars_dated$edge.length * 10
mars_dated$root.time <- max(branching.times(mars_dated))

# Plot dating analysis
pdf("marsupials_dated.pdf", height = 10, width = 10)
geoscalePhylo(mars_dated,units = c("Period", "Epoch"), boxes = "Epoch", width = 3, cex.age = 1.5, cex.ts = 1.5, cex.tip = 1.5)
dev.off()
```

Q17. What do these dates inferences suggest about the diversification of marsupials with relation to the Cretaceous/Palaeogene mass extinction event, or other major geological transitions?

Q18. What forms uncertainty are missing in this dated tree figure, and how would you consider incorporating them?


