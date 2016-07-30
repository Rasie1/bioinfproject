# with open("img.png", "rb") as imageFile:
#   f = imageFile.read()
#   b = bytearray(f)

import PIL.Image as Image
import numpy as np
import pandas as pd
from numpy import genfromtxt, savetxt
from sklearn import datasets
from sklearn.ensemble import RandomForestClassifier

df = pd.read_csv("updated_scoring2.csv", delimiter=';')
# Species
tumor_groups = pd.DataFrame(df, columns=['positive_tumor_cells', 'pic'])
# Список файлов
pic_names = pd.DataFrame(df, columns=['pic'])

# Открываем все файлы, разбираем их на вектора, прописываем как фичеры в датафрейм c 512x512 колонками
dir_path = ''
features = pd.DataFrame(columns=range(262144))
# print(features.head())
for pic in pic_names:
    pic_path = dir_path + pic
    image = Image.open(pic_path).convert('L')
    image = np.array(image)

    # print(image.view())
    # print(image.shape)

    # Мини-датафрейм под каждый вектор - присоединяем к основному
    image_line = np.reshape(image, image.shape[0]*image.shape[1])
    f = pd.DataFrame(image_line, columns=range(len(image_line)))
    features.append(f, ignore_index=True)
    print(pic, image_line.shape)


print(features.head())

df['is_train'] = np.random.uniform(0, 1, len(df)) <= .75
print(df.head())

# df['positive_tumor_cells'] = pd.Factor(iris.target, iris.target_names)

df.head()

# # train, test = df[df['is_train']==True], df[df['is_train']==False]

# features = df.columns[:4]
# clf = RandomForestClassifier(n_jobs=2)
# y, _ = pd.factorize(train['species'])
# clf.fit(train[features], y)

# preds = iris.target_names[clf.predict(test[features])]
# pd.crosstab(test['species'], preds, rownames=['actual'], colnames=['preds'])


# # path = 'compressed/75_36_8_8_3531_compressed.png'
# # image = Image.open(path).convert('L')
# # image = np.array(image)

# # print(image.view())
# # print(image.shape)

# # image_line = np.reshape(image, image.shape[0]*image.shape[1])
# # print(image_line.shape)
# # # create the training & test sets, skipping the header row with [1:]
# # dataset = genfromtxt(open('Data/train.csv','r'), delimiter=';', dtype='f8')[1:]    
# # target = [x[0] for x in dataset]
# # train = [x[1:] for x in dataset]
# # test = genfromtxt(open('Data/test.csv','r'), delimiter=';', dtype='f8')[1:]

# # # create and train the random forest
# # # multi-core CPUs can use: rf = RandomForestClassifier(n_estimators=100, n_jobs=2)
# # rf = RandomForestClassifier(n_estimators=100)
# # rf.fit(train, target)

# # savetxt('Data/submission2.csv', rf.predict(test), delimiter=',', fmt='%f')
