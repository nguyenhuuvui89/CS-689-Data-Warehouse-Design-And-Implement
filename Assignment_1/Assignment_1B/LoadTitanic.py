import pandas as pd

titanicfile = "titanic.csv"
titanic_ppl = pd.read_csv (titanicfile)
nbr = 0
for index, ttnc_person in titanic_ppl.iterrows():
    print (index, "\t", ttnc_person['Name'])
