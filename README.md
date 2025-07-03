This is a public copy of my dissertation data. Hoepfully this will be useful to somebody! 

I used a codeword generator to keep the names of the actual projects static. 

```r 
library(codename)

codename(type = 'ubuntu', seed = 1994)
# this is just an example 
# third tortoise

```

# Layout 

In saphirestoat: I provide data collection, data cleaning, and analysis scripts for my computational chapter. In this chapter I use Reddit Pushift Dumps and [embedding regressions](https://github.com/prodriguezsosa/conText) to understand how words related to the Holocaust and Nazi Germany are used online. In this chapter I also use trusty dusty [GloVe Wikipedia 2014 + Gigaword 5 embeddings](https://github.com/stanfordnlp/GloVe) to unpack what the nearest neighbors are in a massive corpus. 

In greyblueguppy: I provide all the data collection, data cleaning, and analysis scripts for my main quant chapter. In this chapter I use an online version of the Memorial to The Deported Jews of France to understand the effect of the Holocaust on French voting behavior. Admittedly, the code in this chapter is a little rougher than saphirestoat. Hopefully somebody finds this data helpful and can pickup where I left off with the analysis. The data for this chapter are provided in the github releases. 