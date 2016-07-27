# with open("img.png", "rb") as imageFile:
#   f = imageFile.read()
#   b = bytearray(f)

from sklearn import datasets
import PIL.Image as Image
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from numpy import genfromtxt, savetxt
 


path = 'compressed/75_36_8_8_3531_compressed.png'
image = Image.open(path).convert('L')
image = np.array(image)

print(image.view())
print(image.shape)

image_line = np.reshape(image, image.shape[0]*image.shape[1])
print(image_line.shape)
#create the training & test sets, skipping the header row with [1:]
dataset = genfromtxt(open('Data/train.csv','r'), delimiter=',', dtype='f8')[1:]    
target = [x[0] for x in dataset]
train = [x[1:] for x in dataset]
test = genfromtxt(open('Data/test.csv','r'), delimiter=',', dtype='f8')[1:]

#create and train the random forest
#multi-core CPUs can use: rf = RandomForestClassifier(n_estimators=100, n_jobs=2)
rf = RandomForestClassifier(n_estimators=100)
rf.fit(train, target)

savetxt('Data/submission2.csv', rf.predict(test), delimiter=',', fmt='%f')
