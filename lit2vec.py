from __future__ import division
import gensim, pickle, logging, multiprocessing, datetime, re
import numpy as np
import pandas as pd
from random import shuffle # for multiple passes over the data in random order
import csv, time, sys, pickle, os

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
cores = multiprocessing.cpu_count() - 1

assert gensim.models.doc2vec.FAST_VERSION > -1, "this will be too slow otherwise"

def clean_str(string):
    """
    Tokenization/string cleaning.
    Original from https://github.com/yoonkim/CNN_sentence/blob/master/process_data.py
    """
    string = re.sub(r"[^A-Za-z0-9(),!?\'\`]", " ", string)
    string = re.sub(r"\'s", " \'s", string)
    string = re.sub(r"\'ve", " \'ve", string)
    string = re.sub(r"n\'t", " n\'t", string)
    string = re.sub(r"\'re", " \'re", string)
    string = re.sub(r"\'d", " \'d", string)
    string = re.sub(r"\'ll", " \'ll", string)
    string = re.sub(r",", " , ", string)
    string = re.sub(r"!", " ! ", string)
    string = re.sub(r"\(", " \( ", string)
    string = re.sub(r"\)", " \) ", string)
    string = re.sub(r"\?", " \? ", string)
    string = re.sub(r"\s{2,}", " ", string)
    return string.strip().lower()

dat = pd.read_csv("data/s.csv")
print dat.columns

docs = []
for i in range(dat.shape[0]):
  words = clean_str(dat.iloc[i, 0]).split()
  tags = [str(dat.iloc[i, 1])]
  docs.append(gensim.models.doc2vec.TaggedDocument(words, tags))

print('Done with data loading. Data list is length:', len(docs))

def fit(size, window, passes_over, min_count):
  """ Fit model."""
  print "Fitting model with size, window values of:", size, window
  doc_list = docs[:]  # for reshuffling at each pass over the data
  # PV-DM:
  model = gensim.models.Doc2Vec(size=size, window=window, dm=1, min_count=min_count, workers=cores,
                                # defaults:
                                sample=0, seed=1, hs=1, negative=0, dbow_words=0, dm_mean=0, dm_concat=0, dm_tag_count=1)
  model.build_vocab(docs)
  alpha, min_alpha, passes = (0.025, 0.001, passes_over)
  alpha_delta = (alpha - min_alpha) / passes
  print("Starting the training at %s" % datetime.datetime.now())
  for epoch in range(passes):
    shuffle(doc_list) # shuffles the list ordering but the 'tags' of each keep the right original order of docs
    model.alpha, model.min_alpha = alpha, alpha
    model.train(doc_list)
    print('completed pass %i at alpha %f' % (epoch + 1, alpha))
    alpha -= alpha_delta
  print("Ended the training at %s" % str(datetime.datetime.now()))
  return(model)

model = fit(50, 20, 25, 2)
model.save('models/docs50')

# 2016-06-06 13:56:49,812 : INFO : collected 139517 word types and 66 unique tags from a corpus of 337820 examples and 2359663 words
# 2016-06-06 13:56:49,911 : INFO : min_count=5 retains 31712 unique words (drops 107805)
# 2016-06-06 13:56:49,911 : INFO : min_count leaves 2180641 word corpus (92% of original 2359663)

# 2,493,428 words, 150,962 unique words, 69 unique documents, 352,960 sentences.
# Dropping all words that occur less than 5 times retains 33,541 unique words (drops 117,421), and retains 2,301,328 words (92% of original 2,493,428)
