import gensim, pickle, logging, datetime, csv, sys
import numpy as np
import pandas as pd

MODEL_FP = "models/"
fp = "data/"
model_name = "docs"
words = False

model = gensim.models.Doc2Vec.load(MODEL_FP + model_name)
print model.docvecs.offset2doctag
docvecs = np.array(model.docvecs, dtype = 'float') # ndocs by ndim of vecs
np.savetxt(fp + "docvecs_" + model_name + ".csv", docvecs, delimiter=",")
pd.DataFrame(model.docvecs.offset2doctag).to_csv(fp + 'names_' + model_name + '.csv', header=False, index=False, encoding='utf-8')
assert len(model.index2word)==model.syn0.shape[0]

if words:
  wordvecs = np.array(model.syn0, dtype = 'float') # nwords by ndim of vecs
  np.savetxt(fp + "wordvecs_" + model_name + ".csv", wordvecs, delimiter=",")
  pd.DataFrame(model.index2word).to_csv(fp + 'word_names_' + model_name + '.csv', header=False, index=False, encoding='utf-8')
